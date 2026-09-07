import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mail_up/features/home/data/models/email_models.dart';
import 'package:mail_up/features/home/presentation/providers/mail_provider.dart';
import 'package:mail_up/features/home/presentation/widgets/label_creation_dialog.dart';

class LabelFilterBar extends ConsumerWidget {
  const LabelFilterBar({super.key});

  static const _prioritySystemIds = [
    'INBOX',
    'STARRED',
    'IMPORTANT',
    'SENT',
    'DRAFT',
    'CATEGORY_PERSONAL',
    'CATEGORY_PROMOTIONS',
    'CATEGORY_UPDATES',
    'CATEGORY_SOCIAL',
  ];

  String _displayName(EmailLabel label) {
    switch (label.id) {
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

  IconData _icon(EmailLabel label) {
    switch (label.id) {
      case 'INBOX':
        return Icons.inbox_rounded;
      case 'STARRED':
        return Icons.star_rounded;
      case 'IMPORTANT':
        return Icons.label_important_rounded;
      case 'SENT':
        return Icons.send_rounded;
      case 'DRAFT':
        return Icons.drafts_rounded;
      case 'CATEGORY_PERSONAL':
        return Icons.person_rounded;
      case 'CATEGORY_PROMOTIONS':
        return Icons.local_offer_rounded;
      case 'CATEGORY_UPDATES':
        return Icons.update_rounded;
      case 'CATEGORY_SOCIAL':
        return Icons.people_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelsAsync = ref.watch(mailLabelsProvider);
    final selectedId = ref.watch(selectedLabelIdProvider);

    return labelsAsync.when(
      loading: () => const SizedBox(height: 52),
      error: (e, s) => const SizedBox(height: 52),
      data: (labels) {
        final systemLabels = _prioritySystemIds.map((id) {
          final matches = labels.where((l) => l.id == id);
          return matches.isEmpty ? null : matches.first;
        }).whereType<EmailLabel>().toList();

        final userLabels = labels.where((l) => l.type == 'user').toList();
        final allChips = [...systemLabels, ...userLabels];

        return SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: allChips.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == allChips.length) {
                return ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('New'),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => const LabelCreationDialog(),
                  ),
                );
              }

              final label = allChips[index];
              final isSelected = label.id == 'INBOX'
                  ? selectedId == null || selectedId == 'INBOX'
                  : selectedId == label.id;

              return FilterChip(
                avatar: Icon(_icon(label), size: 16),
                label: Text(_displayName(label)),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (_) {
                  ref
                      .read(selectedLabelIdProvider.notifier)
                      .set(label.id == 'INBOX' ? null : label.id);
                },
              );
            },
          ),
        );
      },
    );
  }
}
