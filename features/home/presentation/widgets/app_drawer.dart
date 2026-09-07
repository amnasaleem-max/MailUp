import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mail_up/core/router/router_definitions.dart';
import 'package:mail_up/features/auth/presentation/providers/auth_provider.dart';
import 'package:mail_up/features/home/data/models/email_models.dart';
import 'package:mail_up/features/home/presentation/providers/mail_provider.dart';
import 'package:mail_up/features/home/presentation/widgets/label_creation_dialog.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  static const _systemLabelOrder = [
    'INBOX',
    'STARRED',
    'IMPORTANT',
    'SENT',
    'DRAFT',
    'SPAM',
    'TRASH',
  ];

  static const _categoryOrder = [
    'CATEGORY_PERSONAL',
    'CATEGORY_PROMOTIONS',
    'CATEGORY_UPDATES',
    'CATEGORY_SOCIAL',
    'CATEGORY_FORUMS',
  ];

  String _systemDisplayName(String id) {
    switch (id) {
      case 'INBOX':
        return 'Inbox';
      case 'STARRED':
        return 'Starred';
      case 'IMPORTANT':
        return 'Important';
      case 'SENT':
        return 'Sent';
      case 'DRAFT':
        return 'Drafts';
      case 'SPAM':
        return 'Spam';
      case 'TRASH':
        return 'Trash';
      case 'CATEGORY_PERSONAL':
        return 'Personal';
      case 'CATEGORY_PROMOTIONS':
        return 'Promotions';
      case 'CATEGORY_UPDATES':
        return 'Updates';
      case 'CATEGORY_SOCIAL':
        return 'Social';
      case 'CATEGORY_FORUMS':
        return 'Forums';
      default:
        return id;
    }
  }

  IconData _systemIcon(String id) {
    switch (id) {
      case 'INBOX':
        return Bootstrap.inbox_fill;
      case 'STARRED':
        return Bootstrap.star_fill;
      case 'IMPORTANT':
        return Bootstrap.bookmark_fill;
      case 'SENT':
        return Bootstrap.send_fill;
      case 'DRAFT':
        return Bootstrap.file_earmark_text;
      case 'SPAM':
        return Bootstrap.shield_exclamation;
      case 'TRASH':
        return Bootstrap.trash3_fill;
      case 'CATEGORY_PERSONAL':
        return Bootstrap.person_fill;
      case 'CATEGORY_PROMOTIONS':
        return Bootstrap.tag_fill;
      case 'CATEGORY_UPDATES':
        return Bootstrap.arrow_clockwise;
      case 'CATEGORY_SOCIAL':
        return Bootstrap.people_fill;
      case 'CATEGORY_FORUMS':
        return Bootstrap.chat_fill;
      default:
        return Bootstrap.folder_fill;
    }
  }

  Color _systemIconColor(String id, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (id) {
      case 'INBOX':
        return cs.primary;
      case 'STARRED':
        return Colors.amber[700]!;
      case 'IMPORTANT':
        return Colors.orange;
      case 'SENT':
        return cs.tertiary;
      case 'DRAFT':
        return Colors.blueGrey;
      case 'SPAM':
        return Colors.red;
      case 'TRASH':
        return Colors.red.shade300;
      case 'CATEGORY_PERSONAL':
        return Colors.green;
      case 'CATEGORY_PROMOTIONS':
        return Colors.purple;
      case 'CATEGORY_UPDATES':
        return Colors.teal;
      case 'CATEGORY_SOCIAL':
        return Colors.blue;
      default:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelsAsync = ref.watch(mailLabelsProvider);
    final selectedId = ref.watch(selectedLabelIdProvider);
    final user = ref.watch(authRepositoryProvider).currentUser;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          _DrawerHeader(user: user),

          // Label list
          Expanded(
            child: labelsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (labels) {
                final systemLabels = _systemLabelOrder
                    .map((id) {
                      final matches = labels.where((l) => l.id == id);
                      return matches.isEmpty ? null : matches.first;
                    })
                    .whereType<EmailLabel>()
                    .toList();

                final categoryLabels = _categoryOrder
                    .map((id) {
                      final matches = labels.where((l) => l.id == id);
                      return matches.isEmpty ? null : matches.first;
                    })
                    .whereType<EmailLabel>()
                    .toList();

                final userLabels =
                    labels.where((l) => l.type == 'user').toList();

                return ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    // System labels
                    _SectionTitle(title: 'Mail'),
                    ...systemLabels.map(
                      (label) => _LabelTile(
                        icon: _systemIcon(label.id),
                        iconColor: _systemIconColor(label.id, context),
                        label: _systemDisplayName(label.id),
                        isSelected: label.id == 'INBOX'
                            ? selectedId == null || selectedId == 'INBOX'
                            : selectedId == label.id,
                        onTap: () {
                          ref
                              .read(selectedLabelIdProvider.notifier)
                              .set(label.id == 'INBOX' ? null : label.id);
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    // Category labels
                    if (categoryLabels.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _SectionTitle(title: 'Categories'),
                      ...categoryLabels.map(
                        (label) => _LabelTile(
                          icon: _systemIcon(label.id),
                          iconColor: _systemIconColor(label.id, context),
                          label: _systemDisplayName(label.id),
                          isSelected: selectedId == label.id,
                          onTap: () {
                            ref
                                .read(selectedLabelIdProvider.notifier)
                                .set(label.id);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],

                    // User labels
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionTitle(title: 'Labels'),
                        IconButton(
                          icon: Icon(
                            Icons.add_rounded,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (_) => const LabelCreationDialog(),
                            );
                          },
                          tooltip: 'New Label',
                          padding: const EdgeInsets.only(right: 16),
                        ),
                      ],
                    ),
                    if (userLabels.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        child: Text(
                          'No custom labels yet',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ...userLabels.map(
                        (label) => _LabelTile(
                          icon: Bootstrap.tag_fill,
                          iconColor: Theme.of(context).colorScheme.primary,
                          label: label.name,
                          isSelected: selectedId == label.id,
                          onTap: () {
                            ref
                                .read(selectedLabelIdProvider.notifier)
                                .set(label.id);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    const Divider(height: 24, indent: 20, endIndent: 20),
                    _LabelTile(
                      icon: Bootstrap.whatsapp,
                      iconColor: Colors.green,
                      label: 'WhatsApp Logs',
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(AppRoute.whatsappLogs.name);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final dynamic user;

  const _DrawerHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _LabelTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LabelTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isSelected ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
