import 'package:flutter/material.dart';
import 'package:pacifitcal/config/app_theme.dart';
import 'package:pacifitcal/models/user_model.dart';

class SubscriptionBadge extends StatelessWidget {
  final UserModel user;

  const SubscriptionBadge({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.isAdmin) {
      return _badge(
        icon: Icons.admin_panel_settings,
        label: 'Administrateur',
        color: Colors.purple,
      );
    }

    if (user.isSubscriptionExpired) {
      return _badge(
        icon: Icons.warning_amber_rounded,
        label: 'Abonnement expiré',
        color: AppTheme.error,
      );
    }

    if (user.daysUntilExpiration <= 7) {
      return _badge(
        icon: Icons.access_time,
        label: 'Expire dans ${user.daysUntilExpiration}j',
        color: AppTheme.warning,
      );
    }

    return _badge(
      icon: Icons.verified,
      label: 'Abonnement actif',
      color: AppTheme.success,
    );
  }

  Widget _badge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
