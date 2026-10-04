import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.borderColor,
    this.radius = 26,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppThemeColors.card(context),
        borderRadius: BorderRadius.circular(radius),
        border:
            Border.all(color: borderColor ?? AppThemeColors.stroke(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.06),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: card,
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.brand,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGreen.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: SizedBox(
            height: 56,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 19),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.value,
    this.height = 9,
    this.backgroundColor = const Color(0xFFE9EEF7),
    this.gradient = AppGradients.brand,
  });

  final double value;
  final double height;
  final Color backgroundColor;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: AppThemeColors.isDark(context)
                ? const Color(0xFF2A3552)
                : backgroundColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              width: constraints.maxWidth * safeValue,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.brandBlue,
              ),
            ),
          ),
      ],
    );
  }
}

class PlanoraLogo extends StatelessWidget {
  const PlanoraLogo({
    super.key,
    this.size = 58,
    this.showText = false,
    this.lightText = false,
  });

  final double size;
  final bool showText;
  final bool lightText;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: const CustomPaint(
        painter: _PlanoraMonthlyOrbitPainter(),
      ),
    );

    if (!showText) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 12),
        Text(
          'Planora',
          style: TextStyle(
            color:
                lightText ? Colors.white : AppThemeColors.textPrimary(context),
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}

class _PlanoraMonthlyOrbitPainter extends CustomPainter {
  const _PlanoraMonthlyOrbitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = diameter * 0.30;
    final strokeWidth = diameter * 0.0273;
    final ring = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFF7F8FC).withValues(alpha: 0.23)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    canvas.drawArc(
      ring,
      -math.pi / 2,
      math.pi / 3,
      false,
      Paint()
        ..color = AppColors.brandGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    const endpointAngle = -math.pi / 6;
    final endpoint = Offset(
      center.dx + radius * math.cos(endpointAngle),
      center.dy + radius * math.sin(endpointAngle),
    );
    canvas.drawCircle(
      endpoint,
      diameter * 0.0205,
      Paint()..color = AppColors.brandBlue,
    );

    final initial = TextPainter(
      text: TextSpan(
        text: 'P',
        style: TextStyle(
          color: const Color(0xFFF7F8FC),
          fontFamily: 'SF Pro Display',
          fontSize: diameter * 0.447,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    initial.paint(
      canvas,
      Offset(
        center.dx - initial.width / 2,
        center.dy - initial.height / 2 - diameter * 0.005,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _PlanoraMonthlyOrbitPainter oldDelegate) =>
      false;
}
