import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mail_up/features/home/data/models/email_models.dart';
import 'package:mail_up/features/home/presentation/providers/mail_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mail_up/features/ai/data/services/gemini_service.dart';
import 'package:mail_up/features/settings/presentation/providers/ai_settings_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SummaryDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? extra;

  const SummaryDetailScreen({super.key, this.extra});

  @override
  ConsumerState<SummaryDetailScreen> createState() =>
      _SummaryDetailScreenState();
}

class _SummaryDetailScreenState extends ConsumerState<SummaryDetailScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  EmailMessage? _email;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEmail();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                // Adjust height if needed
              });
            }
          },
        ),
      );
  }

  Future<void> _loadEmail() async {
    final emailId = widget.extra?['emailId'] as String?;
    final initialEmail = widget.extra?['email'] as EmailMessage?;

    if (initialEmail != null) {
      // We have some data, but maybe not body
      _email = initialEmail;

      if (_email!.body != null) {
        _loadContent(_email!.body!);
        setState(() => _isLoading = false);
        return;
      }
    }

    if (emailId == null && initialEmail == null) {
      setState(() {
        _errorMessage = 'Email not found';
        _isLoading = false;
      });
      return;
    }

    final idToFetch = emailId ?? initialEmail!.id;

    try {
      final fullEmail = await ref
          .read(mailRepositoryProvider)
          .fetchEmailDetails(idToFetch);
      if (mounted) {
        setState(() {
          _email = fullEmail;
          _isLoading = false;
          if (_email?.body != null) {
            _loadContent(_email!.body!);
          } else {
            _loadContent('<i>No content</i>');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load email: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _loadContent(String content) {
    // Wrap content for better mobile display
    final htmlContent =
        '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; font-size: 16px; line-height: 1.6; color: #333; padding: 16px; }
          img { max-width: 100%; height: auto; }
          a { color: #007AFF; text-decoration: none; }
        </style>
      </head>
      <body>
        $content
      </body>
      </html>
    ''';

    _webViewController.loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    final aiSettings = ref.watch(aiSettingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Detail'),
        actions: [
          if (aiSettings.isEnabled)
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Summarize with AI',
              onPressed: _summarizeEmail,
            ),
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: () {
              if (_email != null) {
                showDialog(
                  context: context,
                  builder: (_) => _LabelManagementDialog(email: _email!),
                );
              }
            },
          ),
          // Info button to show read-only status
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Read Only'),
                  content: const Text(
                    'Sending and replying to emails is not supported in this app.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (_email == null) {
      return const Center(child: Text('Email not found'));
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _email!.subject,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      _email!.sender.isNotEmpty
                          ? _email!.sender[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _email!.sender,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatDate(_email!.date),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_email!.attachments.isNotEmpty) ...[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _email!.attachments
                        .map(
                          (att) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(
                                att.filename,
                                style: const TextStyle(fontSize: 12),
                              ),
                              avatar: const Icon(Icons.attachment, size: 16),
                              backgroundColor: Colors.grey.shade100,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Body
        Expanded(child: WebViewWidget(controller: _webViewController)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _summarizeEmail() async {
    if (_email == null || _email!.body == null) return;

    // Show loading/result bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _SummaryBottomSheet(emailContent: _email!.body!),
    );
  }
}

class _SummaryBottomSheet extends ConsumerStatefulWidget {
  final String emailContent;

  const _SummaryBottomSheet({required this.emailContent});

  @override
  ConsumerState<_SummaryBottomSheet> createState() =>
      _SummaryBottomSheetState();
}

class _SummaryBottomSheetState extends ConsumerState<_SummaryBottomSheet> {
  String? _summary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateSummary();
  }

  Future<void> _generateSummary() async {
    try {
      final summary = await ref
          .read(geminiServiceProvider)
          .summarizeEmail(widget.emailContent);
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Summary',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Generating summary...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : _error != null
                ? Center(
                    child: Text(
                      'Error: $_error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : SingleChildScrollView(
                    child: Text(
                      _summary ?? '',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  ).animate().fadeIn().slideY(
                    begin: 0.1,
                    end: 0,
                    duration: const Duration(milliseconds: 500),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LabelManagementDialog extends ConsumerWidget {
  final EmailMessage email;

  const _LabelManagementDialog({required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelsAsync = ref.watch(mailLabelsProvider);

    return AlertDialog(
      title: const Text('Manage Labels'),
      content: SizedBox(
        width: double.maxFinite,
        child: labelsAsync.when(
          data: (labels) {
            // Filter out system labels that cannot be modified (optional, but Gmail strictness)
            // System labels like INBOX, TRASH can be modified? Yes (move to trash, archive).
            // But usually we just show user labels + 'INBOX' for basic management.
            // For now show all, Gmail API handles errors or we handle specific logic like 'trash' separately?
            // Actually toggling 'TRASH' label moves to trash.

            final userLabels = labels.where((l) => l.type == 'user').toList();
            final systemLabels = labels
                .where(
                  (l) =>
                      l.type == 'system' &&
                      [
                        'INBOX',
                        'STARRED',
                        'IMPORTANT',
                        'SPAM',
                        'TRASH',
                      ].contains(l.id),
                )
                .toList();

            final allLabels = [...systemLabels, ...userLabels];

            // Real-time state of labels for THIS email is in `email.labelIds`.
            // But we want to observe changes.
            // However, `email` passed in might be stale if we modify it.
            // We should watch the email from provider?
            // `mailInboxProvider` has the list.
            // Or just trust the `email.labelIds` for initial state and use local state in dialog?
            // Better: Local state in dialog, apply changes on tap immediately?
            // Or apply on "Done"?
            // Immediate toggle is standard android pattern.

            // We need a way to know if a label is applied.
            // But `email` object is immutable.
            // We can check `email.labelIds`.
            // BUT if we toggle, we trigger `toggleLabel` in provider, which updates local state.
            // The `email` passed to this widget is NOT automatically updated unless parent rebuilds.
            // So we should find the email in the provider to get latest state?

            // Let's rely on `ref.read` to find current email state.
            // Actually, querying the provider is expensive.
            // We will make `_LabelManagementDialog` stateful or setup a watcher?

            // Simplest: Watch the specific email?
            // We don't have a specific `emailProvider(id)`.
            // We can just check `ref.watch(mailInboxProvider(labelId: ...))` filtering for this email.
            // But we don't know which `labelId` view the user came from.
            // The `SummaryDetailScreen` does not know the strict context.

            // Fallback: Just use `StatefulWidget` and optimistic local state + provider call.

            return ListView.builder(
              shrinkWrap: true,
              itemCount: allLabels.length,
              itemBuilder: (context, index) {
                final label = allLabels[index];
                final isApplied = email.labelIds.contains(label.id);
                // We use a StateProvider or local state to track immediate changes if we want UI to update
                // while dialog is open.
                // Since `email` is final, we need a local set of labelIds.

                return _LabelCheckboxListItem(
                  label: label,
                  initialValue: isApplied,
                  onChanged: (value) {
                    // Trigger provider action
                    // We need the labelId of the VIEW to know which provider to update?
                    // `MailInbox` provider is family. `toggleLabel` is on `MailInbox`.
                    // If we are in 'INBOX', we should update `mailInboxProvider(labelId: null)`.
                    // If we are in 'Projects', we should update `mailInboxProvider(labelId: 'Projects')`.
                    // We don't know!
                    // This is a problem with the provider design.
                    // `modifyEmailLabels` is global (repository).
                    // But `MailInbox` optimistic update depends on the specific provider instance.

                    // Solution: Iterate all `MailInbox` instances? No.
                    // Use a global event bus? No.
                    // Just use `ref.invalidate(mailInboxProvider)`?
                    // Or `ref.read(mailRepositoryProvider).modifyEmailLabels` and then refresher.

                    // I'll call `toggleLabel` on the *default* inbox provider for now or
                    // try to guess.
                    // Actually, `toggleLabel` logic in `MailInbox` handles optimistic update for THAT list.
                    // If we are viewing a different list, it won't update UI immediately.

                    // I will define `toggleLabel` on `mailInboxProvider` but also we might need to invalidate.
                    // Let's just use `ref.read(mailInboxProvider().notifier).toggleLabel(...)`
                    // assuming user is mostly in Inbox.
                    // Ideally we pass `labelId` (view source) to `SummaryDetailScreen` and thus to here. Doable?
                    // `SummaryDetailScreen` extra map has `emailId` and `email`.
                    // I can add `sourceLabelId`.

                    // For now, I'll use `ref.read(mailInboxProvider(labelId: ref.read(selectedLabelIdProvider))).notifier).toggleLabel(...)`.
                    // This covers the current view!
                    final selectedLabelId = ref.read(selectedLabelIdProvider);
                    ref
                        .read(
                          mailInboxProvider(labelId: selectedLabelId).notifier,
                        )
                        .toggleLabel(email.id, label.id);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _LabelCheckboxListItem extends StatefulWidget {
  final EmailLabel label;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const _LabelCheckboxListItem({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_LabelCheckboxListItem> createState() => _LabelCheckboxListItemState();
}

class _LabelCheckboxListItemState extends State<_LabelCheckboxListItem> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.label.name),
      value: _value,
      onChanged: (value) {
        if (value == null) return;
        setState(() => _value = value);
        widget.onChanged(value);
      },
      secondary: const Icon(Icons.label_outline),
    );
  }
}
