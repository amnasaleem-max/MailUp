import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mail_up/features/home/data/models/email_models.dart';
import 'package:mail_up/features/home/presentation/providers/mail_provider.dart';

class LabelAssignSheet extends ConsumerWidget {
  final EmailMessage email;

  const LabelAssignSheet({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelsAsync = ref.watch(mailLabelsProvider);
    final selectedLabelId = ref.watch(selectedLabelIdProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign Label',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email.subject,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        labelsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(20),
            child: Text('Error loading labels: $e'),
          ),
          data: (labels) {
            final userLabels =
                labels.where((l) => l.type == 'user').toList();
            if (userLabels.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No custom labels yet.\nTap the "New" chip in the filter bar to create one.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userLabels.length,
              itemBuilder: (context, index) {
                final label = userLabels[index];
                final hasLabel = email.labelIds.contains(label.id);
                return CheckboxListTile(
                  secondary: Icon(
                    Icons.label_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(label.name),
                  value: hasLabel,
                  controlAffinity: ListTileControlAffinity.trailing,
                  onChanged: (_) {
                    ref
                        .read(
                          mailInboxProvider(labelId: selectedLabelId).notifier,
                        )
                        .toggleLabel(email.id, label.id);
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        ),
        SizedBox(height: 16 + MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}
