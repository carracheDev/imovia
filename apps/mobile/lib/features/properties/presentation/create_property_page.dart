import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';
import '../../account/data/account_repository.dart';
import '../data/property_draft_repository.dart';
import '../../search/data/search_repository.dart';
import '../../search/presentation/location_picker_sheet.dart';

class CreatePropertyPage extends ConsumerStatefulWidget {
  const CreatePropertyPage({super.key});

  @override
  ConsumerState<CreatePropertyPage> createState() => _CreatePropertyPageState();
}

class _CreatePropertyPageState extends ConsumerState<CreatePropertyPage> {
  static const _categories = <String, String>{
    'ROOM': 'Chambre simple',
    'ROOM_AND_LIVING': 'Chambre-salon',
    'STUDIO': 'Studio',
    'APARTMENT': 'Appartement',
    'HOUSE': 'Maison',
    'VILLA': 'Villa',
    'LAND': 'Terrain',
    'SHOP': 'Boutique',
    'COMMERCIAL_SPACE': 'Local commercial',
    'OFFICE': 'Bureau',
    'WAREHOUSE': 'Entrepôt',
    'OTHER': 'Autre',
  };

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  late final Future<AccountUser> _userFuture = _loadUser();
  String? _category;
  String? _operationType;
  SearchLocation? _location;
  PropertyDraft? _createdDraft;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<AccountUser> _loadUser() async {
    final token = await ref.read(sessionTokenStoreProvider).readToken();
    if (token == null || token.isEmpty) {
      throw const ApiException('Authentication required.');
    }
    return ref.read(accountRepositoryProvider).currentUser();
  }

  Future<void> _chooseLocation() async {
    final location = await showModalBottomSheet<SearchLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPickerSheet(
        title: 'Choisir un quartier',
        allowAnySelection: false,
      ),
    );
    if (location != null) setState(() => _location = location);
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null || _operationType == null || _location == null) {
      setState(() => _error = 'Complète le type, l’opération et le quartier.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final draft = await ref
          .read(propertyDraftRepositoryProvider)
          .createDraft(
            title: _titleController.text,
            description: _descriptionController.text,
            category: _category!,
            operationType: _operationType!,
            locationId: _location!.id,
            price: _priceController.text,
          );
      if (mounted) setState(() => _createdDraft = draft);
    } on ApiException catch (error) {
      if (mounted) {
        final message = switch (error.statusCode) {
          401 => 'Ta session a expiré. Reconnecte-toi puis réessaie.',
          403 => 'Ton profil ne peut pas encore créer cette annonce.',
          _ => 'Le brouillon n’a pas pu être enregistré. Vérifie ta connexion puis réessaie.',
        };
        setState(() => _error = message);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      // The setup flow replaces its route before opening the draft form.
      context.go('/advertiser/setup');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ImoviaColors.page,
    appBar: AppBar(
      leading: IconButton(
        onPressed: _goBack,
        tooltip: 'Retour',
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text(
        'Nouvelle annonce',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
    body: FutureBuilder<AccountUser>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _CreateState(
            icon: Icons.lock_outline_rounded,
            title: 'Connecte-toi pour publier',
            body: 'La publication d’une annonce nécessite un compte propriétaire.',
            action: FilledButton(
              onPressed: () =>
                  context.go('/login?returnTo=/advertiser/properties/new'),
              child: const Text('Se connecter'),
            ),
          );
        }

        final user = snapshot.data!;
        if (!user.roles.contains('OWNER')) {
          return _CreateState(
            icon: Icons.real_estate_agent_outlined,
            title: 'Annonce pour un propriétaire',
            body: 'Le propriétaire doit créer le brouillon depuis son compte. Le parcours agent sera relié à l’autorisation du propriétaire dans une prochaine étape.',
            action: OutlinedButton(
              onPressed: () => context.go('/'),
              child: const Text('Revenir à l’accueil'),
            ),
          );
        }

        final draft = _createdDraft;
        if (draft != null) return _DraftCreated(draft: draft);
        return _form(context);
      },
    ),
  );

  Widget _form(BuildContext context) => Form(
    key: _formKey,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: [
        Text(
          'Décrivez le bien',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 5),
        Text(
          'Les informations pourront être complétées avant l’envoi à la validation.',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: ImoviaColors.gray),
        ),
        const SizedBox(height: 20),
        _FormSection(
          title: 'Informations principales',
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Titre de l’annonce',
                  hintText: 'Ex. Villa avec jardin à Cotonou',
                ),
                validator: (value) {
                  final title = value?.trim() ?? '';
                  if (title.length < 5) return 'Saisis au moins 5 caractères.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Type de bien'),
                items: _categories.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _category = value),
                validator: (value) =>
                    value == null ? 'Choisis un type de bien.' : null,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Opération',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _OperationChoice(
                      label: 'À louer',
                      selected: _operationType == 'RENT',
                      onTap: () => setState(() => _operationType = 'RENT'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _OperationChoice(
                      label: 'À vendre',
                      selected: _operationType == 'SALE',
                      onTap: () => setState(() => _operationType = 'SALE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _FormSection(
          title: 'Localisation et budget',
          child: Column(
            children: [
              Material(
                color: ImoviaColors.white,
                borderRadius: BorderRadius.circular(16),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: ImoviaColors.brandAccent,
                  ),
                  title: Text(_location?.name ?? 'Choisir un quartier'),
                  subtitle: Text(
                    _location == null
                        ? 'Arrondissement ou quartier'
                        : _locationLevelLabel(_location!.level),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _chooseLocation,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: ImoviaColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Prix en FCFA (facultatif)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _FormSection(
          title: 'Description',
          child: TextFormField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 5,
            maxLines: 8,
            maxLength: 5000,
            decoration: const InputDecoration(
              hintText: 'Décris le bien, ses pièces et ses principaux atouts…',
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if ((value?.trim().length ?? 0) < 20) {
                return 'La description doit contenir au moins 20 caractères.';
              }
              return null;
            },
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: ImoviaColors.danger)),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _saving ? null : _saveDraft,
          icon: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Enregistrement…' : 'Enregistrer le brouillon'),
        ),
        const SizedBox(height: 10),
        Text(
          'Les photos et la demande de validation seront ajoutées ensuite.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: ImoviaColors.gray),
        ),
      ],
    ),
  );
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: ImoviaColors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: ImoviaColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _OperationChoice extends StatelessWidget {
  const _OperationChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? ImoviaColors.brandAccentSoft : ImoviaColors.white,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? ImoviaColors.brandAccent : ImoviaColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? ImoviaColors.brandAccent : ImoviaColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class _CreateState extends StatelessWidget {
  const _CreateState({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 50, color: ImoviaColors.brandAccent),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: ImoviaColors.gray),
          ),
          const SizedBox(height: 20),
          action,
        ],
      ),
    ),
  );
}

class _DraftCreated extends StatelessWidget {
  const _DraftCreated({required this.draft});

  final PropertyDraft draft;

  @override
  Widget build(BuildContext context) => _CreateState(
    icon: Icons.check_circle_outline_rounded,
    title: 'Brouillon enregistré',
    body:
        '« ${draft.title} » est enregistré. Ajoute ses photos et vérifie les détails avant de demander sa publication.',
    action: Column(
      children: [
        FilledButton(
          onPressed: () => context.go('/'),
          child: const Text('Revenir à l’accueil'),
        ),
        TextButton(
          onPressed: () => context.go('/advertiser/properties/new'),
          child: const Text('Créer une autre annonce'),
        ),
      ],
    ),
  );
}

String _locationLevelLabel(String level) => switch (level) {
  'DEPARTMENT' => 'Département',
  'COMMUNE' => 'Commune',
  'ARRONDISSEMENT' => 'Arrondissement',
  'NEIGHBORHOOD' => 'Quartier',
  _ => 'Localisation',
};
