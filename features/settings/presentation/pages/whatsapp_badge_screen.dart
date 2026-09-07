import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mail_up/features/home/data/models/email_models.dart';
import 'package:mail_up/features/home/presentation/providers/mail_provider.dart';
import 'package:mail_up/features/settings/presentation/providers/whatsapp_badge_provider.dart';
import 'package:mail_up/features/settings/presentation/providers/whatsapp_settings_provider.dart';

class WhatsAppBadgeScreen extends ConsumerWidget {
  const WhatsAppBadgeScreen({super.key});

  // Labels to show in forwarding rules (exclude noise)
  static const _systemLabelIds = [
    'INBOX',
    'STARRED',
    'IMPORTANT',
    'CATEGORY_PERSONAL',
    'CATEGORY_PROMOTIONS',
    'CATEGORY_UPDATES',
    'CATEGORY_SOCIAL',
  ];

  String _labelDisplayName(EmailLabel label) {
    switch (label.id) {
      case 'INBOX':
        return 'Inbox';
      case 'STARRED':
        return 'Starred';
      case 'IMPORTANT':
        return 'Important';
      case 'CATEGORY_PERSONAL':
        return 'Personal';
      case 'CATEGORY_PROMOTIONS':
        return 'Promotions';
      case 'CATEGORY_UPDATES':
        return 'Updates';
      case 'CATEGORY_SOCIAL':
        return 'Social';
      default:
        return label.name;
    }
  }

  IconData _labelIcon(EmailLabel label) {
    switch (label.id) {
      case 'INBOX':
        return Bootstrap.inbox_fill;
      case 'STARRED':
        return Bootstrap.star_fill;
      case 'IMPORTANT':
        return Bootstrap.bookmark_fill;
      case 'CATEGORY_PERSONAL':
        return Bootstrap.person_fill;
      case 'CATEGORY_PROMOTIONS':
        return Bootstrap.tag_fill;
      case 'CATEGORY_UPDATES':
        return Bootstrap.arrow_clockwise;
      case 'CATEGORY_SOCIAL':
        return Bootstrap.people_fill;
      default:
        return Bootstrap.tag_fill;
    }
  }

  Color _labelColor(EmailLabel label) {
    switch (label.id) {
      case 'INBOX':
        return Colors.blue;
      case 'STARRED':
        return Colors.amber[700]!;
      case 'IMPORTANT':
        return Colors.orange;
      case 'CATEGORY_PERSONAL':
        return Colors.green;
      case 'CATEGORY_PROMOTIONS':
        return Colors.purple;
      case 'CATEGORY_UPDATES':
        return Colors.teal;
      case 'CATEGORY_SOCIAL':
        return Colors.indigo;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(whatsAppBadgesProvider);
    final badgesNotifier = ref.read(whatsAppBadgesProvider.notifier);
    final settings = ref.watch(whatsAppSettingsProvider);
    final settingsNotifier = ref.read(whatsAppSettingsProvider.notifier);
    final labelsAsync = ref.watch(mailLabelsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Forwarding Rules',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // ── Section 1: Labels ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    icon: Bootstrap.tag_fill,
                    iconColor: Colors.purple,
                    title: 'Forward by Label',
                    subtitle:
                        'Emails arriving in these labels will be forwarded to WhatsApp',
                  ),
                  const SizedBox(height: 12),
                  labelsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Text('Could not load labels: $e'),
                    data: (labels) {
                      final systemLabels = _systemLabelIds
                          .map((id) {
                            final m = labels.where((l) => l.id == id);
                            return m.isEmpty ? null : m.first;
                          })
                          .whereType<EmailLabel>()
                          .toList();

                      final userLabels =
                          labels.where((l) => l.type == 'user').toList();

                      final allLabels = [...systemLabels, ...userLabels];

                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: List.generate(allLabels.length, (index) {
                            final label = allLabels[index];
                            final isEnabled =
                                settings.forwardLabelIds.contains(label.id);
                            final isLast = index == allLabels.length - 1;
                            final color = label.type == 'user'
                                ? Theme.of(context).colorScheme.primary
                                : _labelColor(label);
                            final icon = label.type == 'user'
                                ? Bootstrap.tag_fill
                                : _labelIcon(label);
                            final name = label.type == 'user'
                                ? label.name
                                : _labelDisplayName(label);

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 2,
                                  ),
                                  leading: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Icon(icon, color: color, size: 17),
                                  ),
                                  title: Text(
                                    name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  trailing: Switch(
                                    value: isEnabled,
                                    activeThumbColor: const Color(0xFF25D366),
                                    onChanged: (_) => settingsNotifier
                                        .toggleForwardLabel(label.id),
                                  ),
                                ),
                                if (!isLast)
                                  Divider(
                                    height: 1,
                                    indent: 64,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant
                                        .withValues(alpha: 0.4),
                                  ),
                              ],
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Section 2: Contact Groups ──────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _SectionHeader(
                      icon: Bootstrap.person_fill,
                      iconColor: const Color(0xFF25D366),
                      title: 'Forward by Contact',
                      subtitle:
                          'Emails from these contact groups will be forwarded',
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        _showCreateGroupDialog(context, badgesNotifier),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('New Group'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF25D366),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (badges.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Bootstrap.people,
                        size: 36,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No contact groups yet',
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a group (e.g. "VIP", "Family") and add email addresses to trigger WhatsApp forwarding.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BadgeCard(
                      badge: badges[index],
                      notifier: badgesNotifier,
                    ),
                  ),
                  childCount: badges.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _showCreateGroupDialog(
    BuildContext context,
    WhatsAppBadges notifier,
  ) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Contact Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                hintText: 'e.g. VIP, Family, Boss',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            Text(
              'After creating, add email addresses to this group.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                notifier.addBadge(nameController.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeCard extends ConsumerWidget {
  final WhatsAppBadge badge;
  final WhatsAppBadges notifier;

  const _BadgeCard({required this.badge, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: badge.redirectWhatsApp
            ? Border.all(
                color: const Color(0xFF25D366).withValues(alpha: 0.4),
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      badge.name.isNotEmpty
                          ? badge.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Color(0xFF25D366),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badge.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        badge.contacts.isEmpty
                            ? 'No contacts added'
                            : '${badge.contacts.length} contact${badge.contacts.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // WhatsApp redirect toggle
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Bootstrap.whatsapp,
                      size: 16,
                      color: badge.redirectWhatsApp
                          ? const Color(0xFF25D366)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    Switch(
                      value: badge.redirectWhatsApp,
                      activeThumbColor: const Color(0xFF25D366),
                      onChanged: (val) =>
                          notifier.toggleRedirect(badge.id, val),
                    ),
                  ],
                ),
                // Delete
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ),

          // Contacts list
          if (badge.contacts.isNotEmpty) ...[
            Divider(
              height: 1,
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
            ...badge.contacts.map(
              (email) => _ContactRow(
                email: email,
                onRemove: () => notifier.removeContact(badge.id, email),
              ),
            ),
          ],

          // Add contact row
          Divider(
            height: 1,
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          InkWell(
            onTap: () => _showAddContactDialog(context),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Add Email Address',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to "${badge.name}"'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'sender@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final email = controller.text.trim();
              if (email.isNotEmpty) {
                notifier.addContact(badge.id, email);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group?'),
        content: Text(
          'This will delete "${badge.name}" and all its contacts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteBadge(badge.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String email;
  final VoidCallback onRemove;

  const _ContactRow({required this.email, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              email,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
