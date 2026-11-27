import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';
import '../../../core/ui/account_bottom_nav.dart';
import '../data/account_repository.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late Future<AccountUser> _userFuture;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  bool _editing = false;
  bool _saving = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    _userFuture = ref.read(accountRepositoryProvider).currentUser();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_firstName.text.trim().isEmpty || _lastName.text.trim().isEmpty) {
      setState(() {
        _message = 'Renseigne ton prénom et ton nom.';
        _messageIsError = true;
      });
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final user = await ref
          .read(accountRepositoryProvider)
          .updateProfile(firstName: _firstName.text, lastName: _lastName.text);
      ref.invalidate(currentAccountProvider);
      if (mounted) {
        setState(() {
          _editing = false;
          _message = 'Profil enregistré.';
          _userFuture = Future.value(user);
        });
      }
    } on ApiException {
      if (mounted) {
        setState(() {
          _message = 'Le profil n’a pas pu être enregistré.';
          _messageIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ImoviaColors.page,
    appBar: AppBar(
      title: Text('Mon profil', style: Theme.of(context).textTheme.titleLarge),
      actions: [
        IconButton(
          tooltip: 'Paramètres',
          onPressed: () => context.push<void>('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    ),
    body: FutureBuilder<AccountUser>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ProfileError(
            onRetry: () => setState(
              () => _userFuture = ref
                  .read(accountRepositoryProvider)
                  .currentUser(),
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
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ImoviaColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ImoviaColors.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: ImoviaColors.lightGray,
                    child: Text(
                      _initials(user),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${user.firstName ?? ''} ${user.lastName ?? ''}'
                            .trim()
                            .isEmpty
                        ? 'Mon compte'
                        : '${user.firstName ?? ''} ${user.lastName ?? ''}'
                              .trim(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (user.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.email!,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: ImoviaColors.gray),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            _LinkRow(
              icon: Icons.add_home_work_outlined,
              title: 'Publier un bien',
              subtitle: 'Créer un profil propriétaire ou agent',
              onTap: () => context.push<void>('/advertiser/setup'),
            ),
            const SizedBox(height: 20),
            Text(
              'Informations personnelles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _editing
                ? TextField(
                    controller: _firstName,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                  )
                : _InfoRow(
                    label: 'Prénom',
                    value: user.firstName ?? 'Non renseigné',
                  ),
            const SizedBox(height: 10),
            _editing
                ? TextField(
                    controller: _lastName,
                    decoration: const InputDecoration(labelText: 'Nom'),
                  )
                : _InfoRow(
                    label: 'Nom',
                    value: user.lastName ?? 'Non renseigné',
                  ),
            const SizedBox(height: 10),
            _InfoRow(
              label: 'Adresse e-mail',
              value: user.email ?? 'Non renseignée',
            ),
            const SizedBox(height: 18),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _messageIsError
                      ? ImoviaColors.danger
                      : ImoviaColors.success,
                ),
              ),
            FilledButton.icon(
              onPressed: _saving
                  ? null
                  : (_editing
                        ? _save
                        : () => setState(() {
                            _editing = true;
                            _message = null;
                            _messageIsError = false;
                          })),
              icon: Icon(_editing ? Icons.check_rounded : Icons.edit_outlined),
              label: Text(
                _saving
                    ? 'Enregistrement…'
                    : _editing
                    ? 'Enregistrer les modifications'
                    : 'Modifier le profil',
              ),
            ),
            const SizedBox(height: 12),
            _LinkRow(
              icon: Icons.notifications_outlined,
              title: 'Notifications essentielles',
              subtitle: 'Voir les actualités du compte',
              onTap: () => context.push<void>('/notifications'),
            ),
            const SizedBox(height: 9),
            _LinkRow(
              icon: Icons.settings_outlined,
              title: 'Paramètres',
              subtitle: 'Préférences et accès au compte',
              onTap: () => context.push<void>('/settings'),
            ),
          ],
        );
      },
    ),
    bottomNavigationBar: AccountBottomNav(selected: 'Profil'),
  );

  String _initials(AccountUser user) {
    final first = user.firstName?.trim() ?? '';
    final last = user.lastName?.trim() ?? '';
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase()
        .ifEmpty('IM');
  }
}

extension on String {
  String ifEmpty(String value) => isEmpty ? value : this;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: ImoviaColors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: ImoviaColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: ImoviaColors.gray),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: ImoviaColors.white,
    borderRadius: BorderRadius.circular(16),
    child: ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ImoviaColors.border),
      ),
      leading: Icon(icon, color: ImoviaColors.ink),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Connecte-toi pour consulter ton profil.'),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => context.push<void>('/login?returnTo=/profile'),
          child: const Text('Se connecter'),
        ),
        TextButton(onPressed: onRetry, child: const Text('Réessayer')),
      ],
    ),
  );
}
