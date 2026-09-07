import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mail_up/core/router/router_definitions.dart';
import 'package:mail_up/features/auth/presentation/pages/email_connection_screen.dart';
import 'package:mail_up/features/home/presentation/pages/home_page.dart';
import 'package:mail_up/features/home/presentation/pages/search_screen.dart';
import 'package:mail_up/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:mail_up/features/settings/presentation/pages/help_center_screen.dart';
import 'package:mail_up/features/splash/presentation/pages/splash_screen.dart';
import 'package:mail_up/features/settings/presentation/pages/whatsapp_settings_screen.dart';
import 'package:mail_up/features/settings/presentation/pages/whatsapp_badge_screen.dart';
import 'package:mail_up/features/settings/presentation/pages/whatsapp_logs_screen.dart';
import 'package:mail_up/features/summary/presentation/pages/summary_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.login.path,
        name: AppRoute.login.name,
        builder: (context, state) => const EmailConnectionScreen(),
      ),
      GoRoute(
        path: AppRoute.whatsappBadges.path,
        name: AppRoute.whatsappBadges.name,
        builder: (context, state) => const WhatsAppBadgeScreen(),
      ),
      GoRoute(
        path: AppRoute.whatsappSettings.path,
        name: AppRoute.whatsappSettings.name,
        builder: (context, state) => const WhatsAppSettingsScreen(),
      ),
      GoRoute(
        path: AppRoute.whatsappLogs.path,
        name: AppRoute.whatsappLogs.name,
        builder: (context, state) => const WhatsAppLogsScreen(),
      ),
      GoRoute(
        path: AppRoute.summaryDetail.path,
        name: AppRoute.summaryDetail.name,
        builder: (context, state) =>
            SummaryDetailScreen(extra: state.extra as Map<String, dynamic>?),
      ),
      GoRoute(
        path: AppRoute.search.path,
        name: AppRoute.search.name,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoute.helpCenter.path,
        name: AppRoute.helpCenter.name,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Error: ${state.error}'))),
  );
});
