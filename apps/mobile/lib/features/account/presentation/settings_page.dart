import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';
import '../data/account_repository.dart';
import 'profile_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late Future<AccountUser> _user;
  bool _signingOut = false;

  @override
  void initState() {
    super.initState();
    _user = ref.read(accountRepositoryProvider).currentUser();
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Tu devras te reconnecter pour retrouver tes favoris et ton profil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _signingOut = true);
    try {
      await ref.read(accountRepositoryProvider).logout();
      await ref.read(sessionTokenStoreProvider).clearToken();
      if (mounted) context.go('/');
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La déconnexion n’a pas abouti. Réessaie.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ImoviaColors.page,
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      title: Text('Paramètres', style: Theme.of(context).textTheme.titleLarge),
    ),
    body: FutureBuilder<AccountUser>(
      future: _user,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Connecte-toi pour gérer ton compte.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () =>
                        context.push<void>('/login?returnTo=/settings'),
                    child: const Text('Se connecter'),
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
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ImoviaColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ImoviaColors.border),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: ImoviaColors.lightGray,
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: ImoviaColors.ink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName ?? ''} ${user.lastName ?? ''}'
                              .trim(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          user.email ?? 'Compte IMOVIA',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: ImoviaColors.gray),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.verified_user_outlined,
                    color: ImoviaColors.gray,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Préférences', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _SettingsRow(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications essentielles',
              subtitle: 'Événements importants du compte',
              trailing: 'Gérer',
              onTap: () => context.push<void>('/notifications'),
            ),
            const SizedBox(height: 9),
            _SettingsRow(
              icon: Icons.contact_phone_outlined,
              title: 'Préférences de contact',
              subtitle: 'Aucune préférence chercheur configurée',
              trailing: null,
              onTap: null,
            ),
            const SizedBox(height: 22),
            Text('Compte', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _SettingsRow(
              icon: Icons.person_outline_rounded,
              title: 'Informations du compte',
              subtitle: 'Nom et adresse e-mail',
              trailing: null,
              onTap: () => context.push<void>('/profile'),
            ),
            const SizedBox(height: 9),
            _SettingsRow(
              icon: Icons.shield_outlined,
              title: 'Accès au compte',
              subtitle: 'Connexion protégée par code de vérification',
              trailing: null,
              onTap: null,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _signingOut ? null : _signOut,
              icon: const Icon(Icons.logout_rounded),
              label: Text(_signingOut ? 'Déconnexion…' : 'Se déconnecter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ImoviaColors.ink,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        );
      },
    ),
    bottomNavigationBar: const AccountBottomNav(selected: 'Profil'),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback? onTap;
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
      trailing: trailing != null
          ? Text(trailing!, style: const TextStyle(fontWeight: FontWeight.w700))
          : onTap != null
          ? const Icon(Icons.chevron_right_rounded)
          : null,
      onTap: onTap,
    ),
  );
}
