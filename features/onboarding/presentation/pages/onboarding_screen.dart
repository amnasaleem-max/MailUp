import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mail_up/core/router/router_definitions.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Email Integration',
      description:
          'Manage all your emails in one place\nwith seamless integration.',
      imagePath: 'assets/images/onboarding_email.png',
    ),
    OnboardingData(
      title: 'AI Powered Insights',
      description:
          'Let AI write better emails and\nsummarize your inbox in seconds.',
      imagePath: 'assets/images/onboarding_ai.png',
    ),
    OnboardingData(
      title: 'WhatsApp Sync',
      description:
          'Connect with WhatsApp to chat\nand share critical updates instantly.',
      imagePath: 'assets/images/onboarding_chat.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.goNamed(AppRoute.login.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensure clean background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  // Key triggers animation reset on new page
                  return OnboardingPage(
                    key: ValueKey(index),
                    data: _onboardingData[index],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _onboardingData.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Theme.of(context).colorScheme.primary,
                      dotColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.15),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 8,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            _currentPage == _onboardingData.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .animate(
                        target: _currentPage == _onboardingData.length - 1
                            ? 1
                            : 0,
                      )
                      .shimmer(
                        duration: 2000.ms,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Expanded(
            flex: 6,
            child:
                Container(
                      // No background color here to keep it clean
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(data.imagePath),
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 400.ms),
          ),
          const SizedBox(height: 40),
          Text(
                data.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .slideY(
                begin: 0.3,
                end: 0,
                duration: 500.ms,
                delay: 200.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 16),
          Text(
                data.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .slideY(
                begin: 0.3,
                end: 0,
                duration: 500.ms,
                delay: 400.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 400.ms, delay: 400.ms),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
