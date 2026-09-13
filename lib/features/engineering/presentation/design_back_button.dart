import 'package:flutter/material.dart';

class DesignBackButton extends StatefulWidget {
  const DesignBackButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Back to Engineering Screen',
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  State<DesignBackButton> createState() => _DesignBackButtonState();
}

class _DesignBackButtonState extends State<DesignBackButton> {
  static const seaBlue = Color(0xFF2AB7E8);

  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pressed ? 1.2 : 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: Tooltip(
        message: widget.tooltip,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (value) => setState(() => pressed = value),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: pressed
                    ? const Color(0xFFD2F2FF)
                    : Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: seaBlue, width: 2),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: seaBlue,
                size: 21,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
