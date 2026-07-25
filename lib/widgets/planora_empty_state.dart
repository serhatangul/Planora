import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'premium_widgets.dart';

class PlanoraEmptyState extends StatelessWidget {
  const PlanoraEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onActionTap,
    this.secondaryActionLabel,
    this.onSecondaryActionTap,
    this.color = AppColors.brandBlue,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryActionTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hasPrimaryAction = actionLabel != null && onActionTap != null;
    final hasSecondaryAction = secondaryActionLabel != null && onSecondaryActionTap != null;

    return PremiumCard(
      color: Colors.white,
      borderColor: AppColors.stroke,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (hasPrimaryAction || hasSecondaryAction) ...[
            const SizedBox(height: 16),
            if (hasPrimaryAction)
              _EmptyStateActionButton(
                label: actionLabel!,
                onTap: onActionTap!,
                color: AppColors.darkNavy,
                textColor: Colors.white,
              ),
            if (hasPrimaryAction && hasSecondaryAction)
              const SizedBox(height: 10),
            if (hasSecondaryAction)
              _EmptyStateActionButton(
                label: secondaryActionLabel!,
                onTap: onSecondaryActionTap!,
                color: color.withOpacity(0.10),
                textColor: color,
              ),
          ],
        ],
      ),
    );
  }
}

class _EmptyStateActionButton extends StatelessWidget {
  const _EmptyStateActionButton({
    required this.label,
    required this.onTap,
    required this.color,
    required this.textColor,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Center(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
