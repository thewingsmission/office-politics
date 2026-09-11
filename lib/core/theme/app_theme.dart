import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.brass,
      onPrimary: AppColors.ink,
      surface: AppColors.ink,
      onSurface: AppColors.paper,
      onSurfaceVariant: AppColors.muted,
      secondary: AppColors.panel,
      onSecondary: AppColors.paper,
      outline: AppColors.panelEdge,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.ink,
      canvasColor: AppColors.ink,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.paper,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: AppColors.paper,
        displayColor: AppColors.paper,
      ),
      splashFactory: NoSplash.splashFactory,
    );
  }
}
