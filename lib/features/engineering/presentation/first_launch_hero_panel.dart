import 'package:flutter/material.dart';

import 'design_back_button.dart';

const double firstLaunchBottomActionXOffset = 15;

class FirstLaunchBottomAction extends StatelessWidget {
  const FirstLaunchBottomAction({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(firstLaunchBottomActionXOffset, 0),
      child: child,
    );
  }
}

class FirstLaunchHeroPanel extends StatelessWidget {
  const FirstLaunchHeroPanel({
    super.key,
    required this.onBack,
    required this.child,
  });

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDDF5FF), Color(0xFFEAE5FF)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -38,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0x35FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesignBackButton(onPressed: onBack),
                const SizedBox(height: 4),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
