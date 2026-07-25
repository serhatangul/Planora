import 'package:flutter/material.dart';

import '../state/planora_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import 'edit_payment_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _openPayment(BuildContext context, String paymentId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanoraScope(
          controller: PlanoraScope.of(context),
          child: EditPaymentScreen(paymentId: paymentId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = PlanoraScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.softBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final lang = controller.appLanguageCode;
            final alerts = controller.smartAlerts;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 34),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _smartAlertsText(lang, 'title'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                PremiumCard(
                  color: AppColors.darkCard,
                  borderColor: AppColors.darkCard,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          controller.activeAlertCount == 0
                              ? _smartAlertsText(lang, 'noCriticalAlerts')
                              : _activeAlertCountText(lang, controller.activeAlertCount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ...alerts.map(
                  (alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AlertCard(
                      alert: alert,
                      onTap: alert.paymentId == null
                          ? null
                          : () => _openPayment(context, alert.paymentId!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                PremiumCard(
                  color: const Color(0xFFF9FBFF),
                  child: Row(
                    children: [
                      const Icon(Icons.info_rounded, color: AppColors.brandBlue),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _smartAlertsText(lang, 'footerNote'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


String _smartAlertsText(String code, String key) {
  final language = code == 'en' || code == 'ru' ? code : 'tr';

  const values = {
    'title': {
      'tr': 'Akıllı Uyarılar',
      'en': 'Smart Alerts',
      'ru': 'Умные уведомления',
    },
    'noCriticalAlerts': {
      'tr': 'Şu an kritik bir ödeme uyarısı yok.',
      'en': 'There are no critical payment alerts right now.',
      'ru': 'Сейчас нет критических уведомлений по платежам.',
    },
    'footerNote': {
      'tr': 'Bu ekran uygulama içi uyarı merkezidir. Gerçek telefon bildirimi sonraki fazda eklenecek.',
      'en': 'This screen is the in-app alert center. Real phone notifications will be added in a later phase.',
      'ru': 'Этот экран — центр уведомлений внутри приложения. Реальные уведомления телефона будут добавлены позже.',
    },
  };

  return values[key]?[language] ?? values[key]?['tr'] ?? key;
}

String _activeAlertCountText(String code, int count) {
  switch (code) {
    case 'en':
      return '$count active payment alerts';
    case 'ru':
      return '$count активных уведомлений по платежам';
    case 'tr':
    default:
      return '$count aktif ödeme uyarın var.';
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    required this.onTap,
  });

  final PlanoraAlert alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = _AlertVisualStyle.fromType(alert.type);

    return PremiumCard(
      onTap: onTap,
      borderColor: style.borderColor,
      color: style.backgroundColor,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: style.iconBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(style.icon, color: style.iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _AlertVisualStyle {
  const _AlertVisualStyle({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;

  factory _AlertVisualStyle.fromType(PlanoraAlertType type) {
    switch (type) {
      case PlanoraAlertType.late:
        return _AlertVisualStyle(
          icon: Icons.warning_rounded,
          iconColor: AppColors.danger,
          iconBackgroundColor: const Color(0xFFFFECEC),
          backgroundColor: Colors.white,
          borderColor: AppColors.danger.withOpacity(0.45),
        );
      case PlanoraAlertType.today:
        return _AlertVisualStyle(
          icon: Icons.today_rounded,
          iconColor: AppColors.warning,
          iconBackgroundColor: const Color(0xFFFFF6E5),
          backgroundColor: Colors.white,
          borderColor: AppColors.warning.withOpacity(0.35),
        );
      case PlanoraAlertType.upcoming:
        return _AlertVisualStyle(
          icon: Icons.schedule_rounded,
          iconColor: AppColors.brandBlue,
          iconBackgroundColor: const Color(0xFFEAF1FF),
          backgroundColor: Colors.white,
          borderColor: AppColors.stroke,
        );
      case PlanoraAlertType.budget:
        return _AlertVisualStyle(
          icon: Icons.account_balance_wallet_rounded,
          iconColor: const Color(0xFF8B5CF6),
          iconBackgroundColor: const Color(0xFFF2EDFF),
          backgroundColor: Colors.white,
          borderColor: const Color(0xFFD9CCFF),
        );
      case PlanoraAlertType.info:
        return _AlertVisualStyle(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.brandGreen,
          iconBackgroundColor: const Color(0xFFE8FFF6),
          backgroundColor: Colors.white,
          borderColor: AppColors.stroke,
        );
    }
  }
}
