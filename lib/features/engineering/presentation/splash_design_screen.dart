import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'design_back_button.dart';

class SplashDesignScreen extends StatefulWidget {
  const SplashDesignScreen({super.key});

  @override
  State<SplashDesignScreen> createState() => _SplashDesignScreenState();
}

class _SplashDesignScreenState extends State<SplashDesignScreen>
    with SingleTickerProviderStateMixin {
  static const logoAsset = 'assets/images/the_wings_mission_logo.png';
  static const baseContentHeight = 402.0 * (19.5 / 9);
  static const seaBlue = Color(0xFF2AB7E8);
  static const engineeringBackground = Color(0xFFF4FAFF);

  late final AnimationController logoFadeControllerDesignScreen;

  @override
  void initState() {
    super.initState();
    logoFadeControllerDesignScreen = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    logoFadeControllerDesignScreen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: engineeringBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final heightScale = constraints.maxHeight / baseContentHeight;
            return Stack(
              children: [
                Center(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: logoFadeControllerDesignScreen,
                      curve: Curves.easeInOut,
                    ),
                    child: Image.asset(
                      logoAsset,
                      width: 180 * heightScale * 1.7,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      color: seaBlue,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: DesignBackButton(
                    onPressed: () => context.go('/engineering'),
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
