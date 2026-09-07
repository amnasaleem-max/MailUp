import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mail_up/features/home/presentation/providers/mail_provider.dart';

class LabelCreationDialog extends ConsumerStatefulWidget {
  const LabelCreationDialog({super.key});

  @override
  ConsumerState<LabelCreationDialog> createState() =>
      _LabelCreationDialogState();
}

class _LabelCreationDialogState extends ConsumerState<LabelCreationDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _createLabel() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(mailLabelsProvider.notifier).createLabel(name);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create label: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Label'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Label Name',
          hintText: 'e.g., Projects, Receipts',
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: _isLoading ? null : _createLabel,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
