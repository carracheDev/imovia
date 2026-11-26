import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/imovia_colors.dart';
import '../data/account_repository.dart';
import 'profile_page.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});
  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  late Future<NotificationPage> _future;
  List<NotificationItem>? _items;
  int _unread = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _future = ref.read(accountRepositoryProvider).notifications();
  }

  Future<void> _reload() async {
    setState(() {
      _error = null;
      _future = ref.read(accountRepositoryProvider).notifications();
    });
    try {
      final result = await _future;
      if (mounted) {
        setState(() {
          _items = result.items;
          _unread = result.unread;
        });
      }
    } on ApiException {
      if (mounted) {
        setState(() => _error = 'Les notifications ne sont pas disponibles.');
      }
    }
  }

  Future<void> _markRead(NotificationItem item) async {
    if (item.read) return;
    try {
      await ref.read(accountRepositoryProvider).markNotificationRead(item.id);
      if (mounted) {
        setState(() {
          _items = _items
              ?.map(
                (value) => value.id == item.id
                    ? NotificationItem(
                        id: value.id,
                        type: value.type,
                        title: value.title,
                        message: value.message,
                        createdAt: value.createdAt,
                        read: true,
                        propertyId: value.propertyId,
                        propertySlug: value.propertySlug,
                      )
                    : value,
              )
              .toList();
          _unread = (_unread - 1).clamp(0, 1 << 30);
        });
      }
    } on ApiException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible de marquer cette notification comme lue.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ImoviaColors.page,
    appBar: AppBar(
      title: Text(
        'Notifications',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        if (_unread > 0)
          IconButton(
            tooltip: 'Tout marquer comme lu',
            onPressed: _markAllRead,
            icon: const Icon(Icons.done_all_rounded),
          ),
      ],
    ),
    body: FutureBuilder<NotificationPage>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError || _error != null) {
          return _NoticeState(
            message: _error ?? 'Impossible de charger les notifications.',
            action: TextButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_items == null) {
          _items = snapshot.data!.items;
          _unread = snapshot.data!.unread;
        }
        if (_items!.isEmpty) {
          return const _NoticeState(
            message: 'Tu n’as aucune notification pour le moment.',
            icon: Icons.notifications_none_rounded,
          );
        }
        return RefreshIndicator(
          color: ImoviaColors.ink,
          onRefresh: _reload,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            itemCount: _items!.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = _items![index];
              return _NotificationCard(
                item: item,
                onTap: () async {
                  await _markRead(item);
                  if (item.propertySlug != null && context.mounted) {
                    context.push<void>(
                      '/properties/${Uri.encodeComponent(item.propertySlug!)}',
                    );
                  }
                },
              );
            },
          ),
        );
      },
    ),
    bottomNavigationBar: const AccountBottomNav(selected: 'Profil'),
  );

  Future<void> _markAllRead() async {
    final unreadItems = (_items ?? []).where((item) => !item.read).toList();
    for (final item in unreadItems) {
      await _markRead(item);
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});
  final NotificationItem item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: item.read ? ImoviaColors.white : const Color(0xFFF9FAFB),
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: ImoviaColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: ImoviaColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _notificationIcon(item.type),
                color: ImoviaColors.ink,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: ImoviaColors.gray),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.createdAt == null
                        ? ''
                        : DateFormat(
                            'd MMM · HH:mm',
                            'fr_FR',
                          ).format(item.createdAt!.toLocal()),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: ImoviaColors.gray),
                  ),
                  if (item.propertySlug != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Ouvrir l’annonce →',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),
            if (!item.read)
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 5, left: 8),
                decoration: const BoxDecoration(
                  color: ImoviaColors.ink,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    ),
  );

  IconData _notificationIcon(String type) => switch (type) {
    'LISTING_APPROVED' ||
    'LISTING_RESTORED' => Icons.check_circle_outline_rounded,
    'LISTING_REJECTED' ||
    'LISTING_SUSPENDED' ||
    'LISTING_NEEDS_CHANGES' => Icons.info_outline_rounded,
    _ => Icons.notifications_none_rounded,
  };
}

class _NoticeState extends StatelessWidget {
  const _NoticeState({
    required this.message,
    this.action,
    this.icon = Icons.notifications_none_rounded,
  });
  final String message;
  final Widget? action;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: ImoviaColors.gray),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    ),
  );
}
