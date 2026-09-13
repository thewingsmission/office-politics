import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.selected = false,
    this.destructive = false,
    this.leading,
    this.height = 49,
    this.visualKey,
    this.animateScale = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool selected;
  final bool destructive;
  final Widget? leading;
  final double height;
  final Key? visualKey;
  final bool animateScale;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool pressed = false;

  bool get enabled => widget.onPressed != null && !widget.busy;

  Color get foreground {
    if (!enabled) return const Color(0xFF8CB9CD);
    return widget.destructive ? AppColors.danger : const Color(0xFF276F9E);
  }

  List<Color> get outlineColors => enabled
      ? const [Color(0xFF3DB9EE), Color(0xFF719CF4), Color(0xFFA386F5)]
      : const [Color(0xFFC9E9F7), Color(0xFFD8E6FA), Color(0xFFE5DDFB)];

  Color get surfaceColor {
    if (!enabled) return const Color(0xFFF7FCFF);
    if (pressed || widget.selected) return const Color(0xFFD2F2FF);
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedScale(
        // The resting control occupies 5/6 of its layout slot. Scaling it to
        // 1.0 produces the requested 1.2× visual growth without crossing the
        // slot boundary and overlapping adjacent controls.
        scale: widget.animateScale ? (pressed ? 1 : 5 / 6) : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: Stack(
          key: widget.visualKey,
          children: [
            Positioned.fill(
              top: 5,
              left: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: outlineColors),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            Positioned.fill(
              right: 5,
              bottom: 5,
              child: _buildForeground(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForeground(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: outlineColors),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: surfaceColor,
        animationDuration: const Duration(milliseconds: 220),
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: enabled ? widget.onPressed : null,
          onHighlightChanged: enabled
              ? (value) => setState(() => pressed = value)
              : null,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          borderRadius: BorderRadius.circular(11),
          child: Center(child: _buildContent(context)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.busy) {
      return SizedBox(
        width: 17,
        height: 17,
        child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.leading != null) ...[
            IconTheme(
              data: IconThemeData(color: foreground, size: 17),
              child: widget.leading!,
            ),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.label,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
