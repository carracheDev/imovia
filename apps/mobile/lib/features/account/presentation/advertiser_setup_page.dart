import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';
import '../data/account_repository.dart';

class AdvertiserSetupPage extends ConsumerStatefulWidget {
  const AdvertiserSetupPage({super.key});

  @override
  ConsumerState<AdvertiserSetupPage> createState() =>
      _AdvertiserSetupPageState();
}

class _AdvertiserSetupPageState extends ConsumerState<AdvertiserSetupPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _displayName = TextEditingController();
  final _businessName = TextEditingController();
  late Future<AccountUser> _userFuture;
  String? _role;
  String? _error;
  bool _saving = false;
  String? _completedRole;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _displayName.dispose();
    _businessName.dispose();
    super.dispose();
  }

  Future<AccountUser> _loadUser() async {
    final token = await ref.read(sessionTokenStoreProvider).readToken();
    if (token == null || token.isEmpty) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/login?returnTo=/advertiser/setup');
        });
      }
      throw const ApiException('Authentication required.');
    }
    final user = await ref.read(accountRepositoryProvider).currentUser();
    final advertiserRole = _existingAdvertiserRole(user.roles);
    if (advertiserRole != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _completedRole = advertiserRole);
      });
    }
    return user;
  }

  Future<void> _save(AccountUser user) async {
    final role = _role;
    if (role == null) {
      setState(() => _error = 'Choisis ton profil annonceur.');
      return;
    }
    if (_firstName.text.trim().isEmpty || _lastName.text.trim().isEmpty) {
      setState(() => _error = 'Renseigne ton prénom et ton nom.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(accountRepositoryProvider)
          .updateProfile(
            firstName: _firstName.text,
            lastName: _lastName.text,
            role: role,
            displayName: _displayName.text,
            businessName: role == 'AGENT' ? _businessName.text : null,
          );
      if (mounted) setState(() => _completedRole = role);
    } on ApiException {
      if (mounted) {
        setState(
          () => _error = 'Impossible d’enregistrer ce profil. Vérifie ta connexion et réessaie.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ImoviaColors.page,
    appBar: AppBar(
      title: Text(
        _completedRole == null ? 'Publier un bien' : 'Profil annonceur',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
    body: FutureBuilder<AccountUser>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 42),
                  const SizedBox(height: 12),
                  const Text(
                    'Connectez-vous pour créer votre profil annonceur.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () =>
                        context.go('/login?returnTo=/advertiser/setup'),
                    child: const Text('Se connecter ou s’inscrire'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = snapshot.data!;
        _firstName.text = _firstName.text.isEmpty
            ? user.firstName ?? ''
            : _firstName.text;
        _lastName.text = _lastName.text.isEmpty
            ? user.lastName ?? ''
            : _lastName.text;
        final existingRole = _existingAdvertiserRole(user.roles);
        final completedRole = _completedRole ?? existingRole;
        if (completedRole != null) {
          return _SetupComplete(role: completedRole);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Text(
              'Quel est votre profil ?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 7),
            Text(
              'Un seul compte IMOVIA suffit. Vous pourrez chercher des biens et gérer vos annonces depuis la même application.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: ImoviaColors.gray, height: 1.45),
            ),
            const SizedBox(height: 20),
            _RoleChoice(
              title: 'Propriétaire',
              subtitle: 'Je publie et gère mes propres biens.',
              icon: Icons.key_outlined,
              selected: _role == 'OWNER',
              onTap: () => setState(() {
                _role = 'OWNER';
                _error = null;
              }),
            ),
            const SizedBox(height: 10),
            _RoleChoice(
              title: 'Agent immobilier',
              subtitle:
                  'Je gère des biens avec l’autorisation de leur propriétaire.',
              icon: Icons.real_estate_agent_outlined,
              selected: _role == 'AGENT',
              onTap: () => setState(() {
                _role = 'AGENT';
                _error = null;
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _firstName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastName,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            if (_role != null) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _displayName,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: _role == 'OWNER'
                      ? 'Nom affiché sur mes annonces (facultatif)'
                      : 'Nom professionnel (facultatif)',
                ),
              ),
            ],
            if (_role == 'AGENT') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _businessName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Agence (facultatif)',
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: ImoviaColors.danger)),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : () => _save(user),
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
              label: Text(_saving ? 'Enregistrement…' : 'Continuer'),
            ),
            const SizedBox(height: 12),
            Text(
              'Votre compte client reste disponible avec ce même profil.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: ImoviaColors.gray),
            ),
          ],
        );
      },
    ),
  );

  String? _existingAdvertiserRole(List<String> roles) {
    if (roles.contains('OWNER')) return 'OWNER';
    if (roles.contains('AGENT')) return 'AGENT';
    return null;
  }
}

class _RoleChoice extends StatelessWidget {
  const _RoleChoice({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? ImoviaColors.brandAccentSoft : ImoviaColors.white,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? ImoviaColors.brandAccent : ImoviaColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: ImoviaColors.brandAccent, size: 25),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: ImoviaColors.gray),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? ImoviaColors.brandAccent : ImoviaColors.gray,
            ),
          ],
        ),
      ),
    ),
  );
}

class _SetupComplete extends StatelessWidget {
  const _SetupComplete({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    final roleName = role == 'OWNER' ? 'propriétaire' : 'agent immobilier';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 58,
              color: ImoviaColors.brandAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Profil $roleName prêt',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Vous gardez aussi l’accès à la recherche et aux favoris avec ce compte.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: ImoviaColors.gray),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Revenir à l’accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
