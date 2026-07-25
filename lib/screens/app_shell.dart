import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import 'add_payment_screen.dart';
import 'analysis_screen.dart';
import 'calendar_screen.dart';
import 'dashboard_screen.dart';
import 'onboarding_setup_screen.dart';
import 'profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final PlanoraController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PlanoraController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  void _goHome() {
    setState(() => _selectedIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      AddPaymentScreen(onSaved: _goHome),
      const CalendarScreen(),
      const AnalysisScreen(),
      const ProfileScreen(),
    ];

    return PlanoraScope(
      controller: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (!_controller.isLoaded) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.brandGreen,
                ),
              ),
            );
          }

          if (!_controller.hasCompletedOnboarding) {
            return const OnboardingSetupScreen();
          }

          return Scaffold(
            extendBody: true,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: screens[_selectedIndex],
            ),
            bottomNavigationBar: _PlanoraBottomNav(
              lang: _controller.appLanguageCode,
              selectedIndex: _selectedIndex,
              onTap: _onTap,
            ),
          );
        },
      ),
    );
  }
}

class _PlanoraBottomNav extends StatelessWidget {
  const _PlanoraBottomNav({
    required this.lang,
    required this.selectedIndex,
    required this.onTap,
  });

  final String lang;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: _navText(lang, 'home')),
      _NavItem(icon: Icons.add_card_rounded, label: _navText(lang, 'payment')),
      _NavItem(icon: Icons.calendar_month_rounded, label: _navText(lang, 'calendar')),
      _NavItem(icon: Icons.pie_chart_rounded, label: _navText(lang, 'analysis')),
      _NavItem(icon: Icons.person_rounded, label: _navText(lang, 'profile')),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.stroke),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkNavy.withOpacity(0.10),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final isActive = index == selectedIndex;
            final item = items[index];

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFFE8FFF6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: isActive ? AppColors.brandGreen : const Color(0xFF8B93A7),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isActive ? AppColors.brandGreen : const Color(0xFF8B93A7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}


String _navText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'home': {
      'tr': 'Ana',
      'en': 'Home',
      'ru': 'Главная',
    },
    'payment': {
      'tr': 'Ödeme',
      'en': 'Payment',
      'ru': 'Платёж',
    },
    'calendar': {
      'tr': 'Takvim',
      'en': 'Calendar',
      'ru': 'Календарь',
    },
    'analysis': {
      'tr': 'Analiz',
      'en': 'Analysis',
      'ru': 'Анализ',
    },
    'profile': {
      'tr': 'Profil',
      'en': 'Profile',
      'ru': 'Профиль',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
