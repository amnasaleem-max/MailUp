enum AppRoute {
  splash(path: '/splash', name: 'splash'),
  onboarding(path: '/onboarding', name: 'onboarding'),
  login(path: '/login', name: 'login'),
  whatsappSettings(path: '/whatsapp-settings', name: 'whatsappSettings'),
  whatsappBadges(path: '/whatsapp-badges', name: 'whatsappBadges'),
  whatsappLogs(path: '/whatsapp-logs', name: 'whatsappLogs'),
  summaryDetail(path: '/summary-detail', name: 'summaryDetail'),
  search(path: '/search', name: 'search'),
  helpCenter(path: '/help-center', name: 'helpCenter'),
  home(path: '/', name: 'home');

  final String path;
  final String name;

  const AppRoute({required this.path, required this.name});
}
