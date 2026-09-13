import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF3D9FD8),
      onPrimary: Colors.white,
      surface: Color(0xFFF4FAFF),
      onSurface: Color(0xFF173F5D),
      onSurfaceVariant: Color(0xFF66859A),
      secondary: Color(0xFF7D9CF6),
      onSecondary: Colors.white,
      outline: Color(0xFFB8DBF5),
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF4FAFF),
      canvasColor: const Color(0xFFF4FAFF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF4FAFF),
        foregroundColor: Color(0xFF173F5D),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: const Color(0xFF173F5D),
        displayColor: const Color(0xFF173F5D),
      ),
      splashFactory: NoSplash.splashFactory,
    );
  }
}
