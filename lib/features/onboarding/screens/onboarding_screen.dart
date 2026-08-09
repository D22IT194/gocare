import 'package:flutter/material.dart';

import '../providers/onboarding_provider.dart';
import '../services/onboarding_service.dart';
import '../widgets/onboarding_indicator.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onFinished,
  });

  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _pageController =
      PageController();

  final OnboardingProvider _provider =
      const OnboardingProvider();

  final OnboardingService _onboardingService =
      OnboardingService();

  int _currentIndex = 0;

  bool _isFinishing = false;

  List get _pages => _provider.onboardingPages;

  bool get _isLastPage =>
      _currentIndex == _pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_isLastPage) {
      await _finishOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _previousPage() async {
    if (_currentIndex == 0) {
      return;
    }

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _skipOnboarding() async {
    await _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    if (_isFinishing) {
      return;
    }

    setState(() {
      _isFinishing = true;
    });

    await _onboardingService.complete();

    if (!mounted) {
      return;
    }

    // Tell AuthGate that onboarding is complete.
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --------------------------------
          // Top bar
          // --------------------------------

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                0,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end,
                children: [
                  if (!_isLastPage)
                    TextButton(
                      onPressed:
                          _isFinishing
                              ? null
                              : _skipOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // --------------------------------
          // Pages
          // --------------------------------

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                if (!mounted) {
                  return;
                }

                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return OnboardingPage(
                  page: _pages[index],
                );
              },
            ),
          ),

          // --------------------------------
          // Bottom controls
          // --------------------------------

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                12,
                24,
                24,
              ),
              child: Column(
                children: [
                  OnboardingIndicator(
                    currentIndex: _currentIndex,
                    itemCount: _pages.length,
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      if (_currentIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                _isFinishing
                                    ? null
                                    : _previousPage,
                            style:
                                OutlinedButton.styleFrom(
                              minimumSize:
                                  const Size.fromHeight(
                                54,
                              ),
                              side:
                                  const BorderSide(
                                color:
                                    Color(0xFF1976D2),
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w600,
                                color:
                                    Color(0xFF1976D2),
                              ),
                            ),
                          ),
                        ),

                      if (_currentIndex > 0)
                        const SizedBox(width: 12),

                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed:
                              _isFinishing
                                  ? null
                                  : _nextPage,
                          style:
                              ElevatedButton.styleFrom(
                            minimumSize:
                                const Size.fromHeight(
                              54,
                            ),
                            backgroundColor:
                                const Color(0xFF1976D2),
                            foregroundColor:
                                Colors.white,
                            elevation: 0,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                            ),
                          ),
                          child: _isFinishing
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _isLastPage
                                      ? 'Get Started'
                                      : 'Next',
                                  style:
                                      const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}