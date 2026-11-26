import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:imovia_mobile/features/home/data/home_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';
import '../data/property_detail_repository.dart';
import '../../account/presentation/profile_page.dart';

class ContactPage extends ConsumerStatefulWidget {
  const ContactPage({super.key, required this.slug});
  final String slug;
  @override
  ConsumerState<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends ConsumerState<ContactPage> {
  late Future<PropertyDetail> _property;
  PropertyContact? _contact;
  bool _loadingContact = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _property = ref.read(propertyDetailRepositoryProvider).load(widget.slug);
  }

  Future<void> _continue() async {
    setState(() {
      _loadingContact = true;
      _error = null;
    });
    try {
      final contact = await ref
          .read(propertyDetailRepositoryProvider)
          .loadContact(widget.slug);
      if (mounted) setState(() => _contact = contact);
    } on ApiException {
      if (mounted) {
        setState(
          () => _error = 'Impossible de récupérer les moyens de contact.',
        );
      }
    } finally {
      if (mounted) setState(() => _loadingContact = false);
    }
  }

  Future<void> _openPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      _showMessage('Aucune application ne peut ouvrir cet appel.');
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.https('wa.me', '/$digits');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      _showMessage('WhatsApp n’est pas disponible sur cet appareil.');
    }
  }

  void _showMessage(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ImoviaColors.page,
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text(
        'Contacter l’annonceur',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
    body: FutureBuilder<PropertyDetail>(
      future: _property,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Cette annonce n’est pas disponible.'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final property = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
          children: [
            Text(
              'Votre demande concerne ce bien',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: ImoviaColors.gray),
            ),
            const SizedBox(height: 16),
            _PropertySummary(property: property),
            const SizedBox(height: 24),
            Text('Annonceur', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 11),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: ImoviaColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ImoviaColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: ImoviaColors.lightGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.call_outlined,
                          color: ImoviaColors.ink,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _contact == null
                                  ? 'Moyen de contact disponible'
                                  : 'Coordonnées de contact',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Selon les préférences de l’annonceur',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: ImoviaColors.gray),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_contact == null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _loadingContact ? null : _continue,
                        icon: _loadingContact
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.call_rounded),
                        label: Text(
                          _loadingContact
                              ? 'Chargement…'
                              : 'Continuer vers le contact',
                        ),
                      ),
                    ),
                  ] else ...[
                    if (_contact!.phone != null) ...[
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _openPhone(_contact!.phone!),
                          icon: const Icon(Icons.phone_rounded),
                          label: Text('Appeler  ${_contact!.phone}'),
                        ),
                      ),
                    ],
                    if (_contact!.whatsApp != null) ...[
                      const SizedBox(height: 9),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _openWhatsApp(_contact!.whatsApp!),
                          icon: const Icon(Icons.chat_outlined),
                          label: Text(
                            'Continuer sur WhatsApp  ${_contact!.whatsApp}',
                          ),
                        ),
                      ),
                    ],
                    if (_contact!.phone == null &&
                        _contact!.whatsApp == null) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Aucun moyen de contact n’est configuré pour cette annonce.',
                      ),
                    ],
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: const TextStyle(color: ImoviaColors.danger),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ImoviaColors.brandAccentSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: ImoviaColors.ink),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Les coordonnées ne sont communiquées que si l’annonceur a autorisé ce moyen de contact.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ImoviaColors.charcoal,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
    bottomNavigationBar: const AccountBottomNav(selected: 'Recherche'),
  );
}

class _PropertySummary extends ConsumerWidget {
  const _PropertySummary({required this.property});
  final PropertyDetail property;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaId = property.media.isEmpty ? null : property.media.first.id;
    final image = mediaId == null
        ? null
        : ref.watch(
            propertyImageUrlProvider(
              PropertyMediaRef(slug: property.slug, mediaId: mediaId),
            ),
          );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ImoviaColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ImoviaColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 112,
              height: 112,
              child: image == null
                  ? Image.asset(
                      'assets/images/villa_exterior.webp',
                      fit: BoxFit.cover,
                    )
                  : image.when(
                      data: (url) => Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/images/villa_exterior.webp',
                          fit: BoxFit.cover,
                        ),
                      ),
                      loading: () => Image.asset(
                        'assets/images/villa_exterior.webp',
                        fit: BoxFit.cover,
                      ),
                      error: (_, _) => Image.asset(
                        'assets/images/villa_exterior.webp',
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (property.locationName != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    property.locationName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: ImoviaColors.gray),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  property.price == null
                      ? 'Prix sur demande'
                      : '${property.price} FCFA${property.operationType == 'RENT' ? ' / mois' : ''}',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
