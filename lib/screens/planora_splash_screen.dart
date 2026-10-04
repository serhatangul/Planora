import 'dart:async';

import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import 'app_shell.dart';

class PlanoraSplashScreen extends StatefulWidget {
  const PlanoraSplashScreen({super.key});

  @override
  State<PlanoraSplashScreen> createState() => _PlanoraSplashScreenState();
}

class _PlanoraSplashScreenState extends State<PlanoraSplashScreen> {
  bool _minimumDurationPassed = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _minimumDurationPassed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);
    final ready = _minimumDurationPassed && controller.isLoaded;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ready
          ? const AppShell(key: ValueKey('planora-app'))
          : const _BrandSplash(key: ValueKey('planora-splash')),
    );
  }
}

class _BrandSplash extends StatelessWidget {
  const _BrandSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.softBg,
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            PlanoraLogo(size: 84, showText: true),
            Positioned(
              bottom: 52,
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: AppColors.brandGreen,
                  strokeWidth: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
