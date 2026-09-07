import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
// ignore_for_file: discarded_futures
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mail_up/core/router/router_definitions.dart';
import 'package:mail_up/core/services/push_notification_service.dart';
import 'package:mail_up/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Minimum splash duration
    final minSplashDuration = const Duration(seconds: 4);
    final startTime = DateTime.now();

    // Check auth status in parallel with timer
    final authCheckFuture = ref.read(authRepositoryProvider).restoreSession();

    // Wait for auth check
    final isAuthenticated = await authCheckFuture;

    // Calculate remaining time
    final elapsedTime = DateTime.now().difference(startTime);
    final remainingTime = minSplashDuration - elapsedTime;

    // Wait for remaining time if any
    if (remainingTime > Duration.zero) {
      await Future.delayed(remainingTime);
    }

    if (!mounted) return;

    if (isAuthenticated) {
      // Silently run background tasks — don't block navigation
      () async {
        try {
          await FirebaseFunctions.instance
              .httpsCallable('reactivateGmailWatch')
              .call();
        } catch (_) {}
        try {
          await pushNotificationService.syncFCMToken();
        } catch (_) {}
      }();
      if (mounted) context.goNamed(AppRoute.home.name);
    } else {
      context.goNamed(AppRoute.onboarding.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFF1B263B), // Matches the generated logo background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/mail_up_logo.png'),
                        fit: BoxFit.contain,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 600.ms),
              const SizedBox(height: 32),

              // App Name Text (Optional addition for branding)
              Text(
                    'MailUp',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  )
                  .animate()
                  .slideY(
                    begin: 0.5,
                    end: 0,
                    duration: 600.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeIn(duration: 600.ms, delay: 300.ms),

              const SizedBox(height: 48),

              // Minimal Loader
              SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.secondary,
                      strokeWidth: 3,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(delay: 1000.ms, duration: 500.ms)
                  .shimmer(
                    duration: 1500.ms,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
