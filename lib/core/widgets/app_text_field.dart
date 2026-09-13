import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';

Future<void> requestAppKeyboard() async {
  await Future<void>.delayed(const Duration(milliseconds: 80));
  await SystemChannels.textInput.invokeMethod<void>('TextInput.show');
}

InputDecoration appInputDecoration({
  String? label,
  String? hint,
  String? error,
  int errorMaxLines = 3,
  String? counterText,
  Widget? prefix,
  Widget? suffix,
  Color fillColor = Colors.white,
  EdgeInsetsGeometry? contentPadding,
}) {
  const normalBorder = BorderSide(color: Color(0xFF3CA9DD), width: 2);
  const focusedBorder = BorderSide(color: Color(0xFF3CA9DD), width: 2);
  const errorBorder = BorderSide(color: Color(0xFFE56E72), width: 2);

  return InputDecoration(
    labelText: label,
    hintText: hint,
    errorText: error,
    errorMaxLines: errorMaxLines,
    counterText: counterText,
    prefixIcon: prefix,
    suffixIcon: suffix,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    isDense: true,
    filled: true,
    fillColor: fillColor,
    contentPadding:
        contentPadding ??
        const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
    labelStyle: const TextStyle(
      color: Color(0xFF318DB6),
      fontSize: 11,
      fontWeight: FontWeight.w800,
    ),
    floatingLabelStyle: const TextStyle(
      color: Color(0xFF318DB6),
      fontSize: 11,
      fontWeight: FontWeight.w800,
    ),
    hintStyle: const TextStyle(
      color: Color(0xFF87A5B6),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: normalBorder,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: focusedBorder,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: errorBorder,
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: errorBorder,
    ),
  );
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      onTap: requestAppKeyboard,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF255873),
        fontWeight: FontWeight.w700,
      ),
      cursorColor: const Color(0xFF3CA9DD),
      decoration: appInputDecoration(
        label: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}
