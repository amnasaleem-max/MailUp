import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mail_up/features/settings/presentation/providers/whatsapp_settings_provider.dart';

class WhatsAppSettingsScreen extends ConsumerWidget {
  const WhatsAppSettingsScreen({super.key});

  static const _whatsAppGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(whatsAppSettingsProvider);
    final notifier = ref.read(whatsAppSettingsProvider.notifier);
    final isEnabled = settings.isEnabled;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Custom header
          SliverToBoxAdapter(
            child: _WhatsAppHeader(isEnabled: isEnabled),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Master toggle card
                _SectionCard(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _whatsAppGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Bootstrap.whatsapp,
                          color: _whatsAppGreen,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WhatsApp Forwarding',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              isEnabled ? 'Active' : 'Disabled',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: isEnabled
                                    ? _whatsAppGreen
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isEnabled,
                        activeThumbColor: _whatsAppGreen,
                        onChanged: notifier.setEnabled,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Destination number
                _SectionLabel(label: 'Destination'),
                const SizedBox(height: 10),
                _SectionCard(
                  onTap: isEnabled
                      ? () => _showNumberDialog(
                            context,
                            settings.destinationNumber,
                            notifier,
                          )
                      : null,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Bootstrap.telephone_fill,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WhatsApp Number',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              settings.destinationNumber.isEmpty
                                  ? 'Tap to set number'
                                  : settings.destinationNumber,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: settings.destinationNumber.isEmpty
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant
                                    : _whatsAppGreen,
                                fontWeight: settings.destinationNumber.isEmpty
                                    ? FontWeight.normal
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isEnabled)
                        Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // What to forward
                _SectionLabel(label: 'What to Forward'),
                const SizedBox(height: 10),
                _SectionCard(
                  child: Column(
                    children: [
                      _ToggleRow(
                        icon: Bootstrap.file_earmark_text,
                        iconColor: Colors.blue,
                        title: 'Email Body',
                        subtitle: 'Include message content in WhatsApp',
                        value: settings.forwardBody,
                        enabled: isEnabled,
                        onChanged: notifier.setForwardBody,
                      ),
                      Divider(
                        height: 1,
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                      _ToggleRow(
                        icon: Bootstrap.paperclip,
                        iconColor: Colors.orange,
                        title: 'Attachments',
                        subtitle: 'Forward supported file attachments',
                        value: settings.forwardAttachments,
                        enabled: isEnabled,
                        onChanged: notifier.setForwardAttachments,
                      ),
                    ],
                  ),
                ),


                // Info note / Connection test
                if (!isEnabled) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Enable WhatsApp Forwarding above to configure your number and forwarding rules.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (settings.destinationNumber.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'Connection Test'),
                  const SizedBox(height: 10),
                  _TestConnectionCard(destinationNumber: settings.destinationNumber),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showNumberDialog(
    BuildContext context,
    String current,
    WhatsAppSettingsNotifier notifier,
  ) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WhatsApp Number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '+1234567890',
            helperText: 'Include country code, e.g. +92...',
            prefixIcon: const Icon(Bootstrap.whatsapp, color: Color(0xFF25D366)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              notifier.setDestinationNumber(controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _WhatsAppHeader extends StatelessWidget {
  final bool isEnabled;

  const _WhatsAppHeader({required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF128C7E), Color(0xFF25D366)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Bootstrap.whatsapp,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WhatsApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isEnabled ? 'Forwarding is active' : 'Forwarding is off',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _SectionCard({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: enabled ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: enabled ? iconColor : iconColor.withValues(alpha: 0.4),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: enabled
                        ? null
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(
                      alpha: enabled ? 1 : 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _TestConnectionCard extends ConsumerStatefulWidget {
  final String destinationNumber;

  const _TestConnectionCard({required this.destinationNumber});

  @override
  ConsumerState<_TestConnectionCard> createState() => _TestConnectionCardState();
}

class _TestConnectionCardState extends ConsumerState<_TestConnectionCard> {
  bool _isLoading = false;

  Future<void> _sendTestMessage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('sendTestWhatsAppMessage')
          .call();

      final data = result.data as Map<dynamic, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test WhatsApp message sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = data['error'] as String? ?? 'Unknown error';
        _showErrorDialog(error);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Test Failed'),
          ],
        ),
        content: Text(
          'Failed to send test message.\n\nError details:\n$error',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Bootstrap.send_fill,
                  color: Colors.blue,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify Integration',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Send a template message to ${widget.destinationNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _sendTestMessage,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Bootstrap.whatsapp, size: 18),
              label: Text(_isLoading ? 'Sending Test...' : 'Send Test Message'),
            ),
          ),
        ],
      ),
    );
  }
}
