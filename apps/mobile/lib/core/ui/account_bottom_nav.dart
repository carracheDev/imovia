import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/imovia_colors.dart';

class AccountBottomNav extends StatelessWidget {
  const AccountBottomNav({super.key, required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ImoviaColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B0B0B),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            label: 'Accueil',
            selected: selected == 'Accueil',
            onTap: () => context.go('/'),
          ),
          _NavItem(
            icon: Icons.search_rounded,
            label: 'Recherche',
            selected: selected == 'Recherche',
            onTap: () => context.go('/search'),
          ),
          _NavItem(
            icon: Icons.favorite_border_rounded,
            label: 'Favoris',
            selected: selected == 'Favoris',
            onTap: () => context.go('/favorites'),
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profil',
            selected: selected == 'Profil',
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 30,
              decoration: BoxDecoration(
                color: selected
                    ? ImoviaColors.brandAccentSoft
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: selected ? ImoviaColors.brandAccent : ImoviaColors.gray,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected ? ImoviaColors.brandAccent : ImoviaColors.gray,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: ImoviaColors.brandAccent,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
