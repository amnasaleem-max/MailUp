import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mail_up/core/router/router_definitions.dart';
import 'package:mail_up/features/auth/presentation/providers/auth_provider.dart';
import 'package:mail_up/features/settings/presentation/providers/whatsapp_settings_provider.dart';
import 'package:mail_up/features/settings/presentation/providers/whatsapp_logs_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous?.isLoading == true) {
            context.goNamed(AppRoute.login.name);
          }
        },
      );
    });

    final user = ref.watch(authRepositoryProvider).currentUser;
    final whatsAppSettings = ref.watch(whatsAppSettingsProvider);
    final logsAsync = ref.watch(whatsappLogsProvider);

    final cleanNum = whatsAppSettings.destinationNumber.replaceAll(RegExp(r'\D'), '');
    final isNumberValid = cleanNum.length >= 10;

    final latestLogFailed = logsAsync.maybeWhen(
      data: (logs) {
        if (logs.isEmpty) return false;
        return logs[0].status == 'failed';
      },
      orElse: () => false,
    );

    final showWhatsAppStatusDot = whatsAppSettings.isEnabled && isNumberValid;
    final statusDotColor = latestLogFailed ? Colors.red : const Color(0xFF25D366);

    final String whatsappSubtitle;
    if (!whatsAppSettings.isEnabled) {
      whatsappSubtitle = 'Disabled';
    } else if (!isNumberValid) {
      whatsappSubtitle = 'Setup WhatsApp number';
    } else if (latestLogFailed) {
      whatsappSubtitle = 'Connection error: last forward failed';
    } else {
      whatsappSubtitle = 'Forwarding to ${whatsAppSettings.destinationNumber}';
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Settings',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Account Card
                _buildAccountCard(context, user?.displayName, user?.email),
                const SizedBox(height: 24),

                // WhatsApp Section
                _buildSectionTitle(context, 'WhatsApp Forwarding'),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  context,
                  icon: Bootstrap.whatsapp,
                  iconColor: const Color(0xFF25D366),
                  title: 'WhatsApp Settings',
                  subtitle: whatsappSubtitle,
                  statusDot: showWhatsAppStatusDot,
                  statusDotColor: statusDotColor,
                  onTap: () =>
                      context.pushNamed(AppRoute.whatsappSettings.name),
                ),
                const SizedBox(height: 8),
                _buildSettingsTile(
                  context,
                  icon: Bootstrap.funnel_fill,
                  iconColor: Colors.purple,
                  title: 'Forwarding Rules',
                  subtitle: 'Labels & contact filters',
                  onTap: () => context.pushNamed(AppRoute.whatsappBadges.name),
                ),
                const SizedBox(height: 24),



                // Support & Account Section
                _buildSectionTitle(context, 'Support & Account'),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  context,
                  icon: Bootstrap.question_circle_fill,
                  iconColor: Colors.blue,
                  title: 'Help Center',
                  subtitle: 'FAQs and how-to guides',
                  onTap: () => context.pushNamed(AppRoute.helpCenter.name),
                ),
                const SizedBox(height: 8),

                // Sign Out tile
                _buildSignOutTile(context, ref),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutTile(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _confirmSignOut(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Bootstrap.box_arrow_right,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Sign Out',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to disconnect your email account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    String? name,
    String? email,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              name?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool statusDot = false,
    Color? statusDotColor,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (statusDot)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: statusDotColor ?? const Color(0xFF25D366),
                  shape: BoxShape.circle,
                ),
              ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}
