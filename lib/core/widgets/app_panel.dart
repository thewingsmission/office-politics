import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.title,
    required this.body,
    required this.kicker,
    this.badge,
    this.onTap,
  });

  final String title;
  final String body;
  final String kicker;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.panelEdge),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        kicker.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.brass,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    if (badge != null)
                      Text(
                        badge!.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.paper,
                          letterSpacing: 1.1,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.paper,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: Text(
                    body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
