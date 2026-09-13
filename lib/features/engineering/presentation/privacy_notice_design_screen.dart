import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'first_launch_hero_panel.dart';

class PrivacyNoticeDesignScreen extends StatefulWidget {
  const PrivacyNoticeDesignScreen({super.key});

  @override
  State<PrivacyNoticeDesignScreen> createState() =>
      _PrivacyNoticeDesignScreenState();
}

class _PrivacyNoticeDesignScreenState extends State<PrivacyNoticeDesignScreen> {
  final List<bool> reviewedItemsDesignScreen = [false, false, false, false];
  bool acceptedDesignScreen = false;

  void toggleItemDesignScreen(int index) {
    setState(() {
      reviewedItemsDesignScreen[index] = !reviewedItemsDesignScreen[index];
      acceptedDesignScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewedCount = reviewedItemsDesignScreen
        .where((item) => item)
        .length;
    final allReviewed = reviewedCount == privacyItemsDesignScreen.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: FirstLaunchHeroPanel(
                  onBack: () => context.go('/engineering'),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(),
                      Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF3299D0),
                        size: 55,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Protect your\nworkplace details',
                        style: TextStyle(
                          color: Color(0xFF174765),
                          fontSize: 24,
                          height: 1.06,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Review how to keep workplace information safe before entering it.',
                        style: TextStyle(
                          color: Color(0xFF56819A),
                          fontSize: 9,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pseudonyms • Secrets • Consultant limits • Data control',
                      style: TextStyle(
                        color: Color(0xFF173F5D),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) => GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent:
                                    (constraints.maxHeight - 14) / 2,
                              ),
                          itemCount: privacyItemsDesignScreen.length,
                          itemBuilder: (context, index) {
                            final item = privacyItemsDesignScreen[index];
                            return _PrivacyItem(
                              item: item,
                              reviewed: reviewedItemsDesignScreen[index],
                              onTap: () => toggleItemDesignScreen(index),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          acceptedDesignScreen
                              ? Icons.verified_rounded
                              : Icons.fact_check_outlined,
                          color: acceptedDesignScreen
                              ? const Color(0xFF358FC4)
                              : const Color(0xFF3A91B8),
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            acceptedDesignScreen
                                ? 'Notice accepted'
                                : '$reviewedCount of 4 items reviewed',
                            style: TextStyle(
                              color: acceptedDesignScreen
                                  ? const Color(0xFF337FA8)
                                  : const Color(0xFF557C90),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        FirstLaunchBottomAction(
                          child: SizedBox(
                            width: 175,
                            child: AppButton(
                              label: 'I Understand',
                              onPressed: allReviewed
                                  ? () => setState(
                                      () => acceptedDesignScreen = true,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  const _PrivacyItem({
    required this.item,
    required this.reviewed,
    required this.onTap,
  });

  final _PrivacyItemData item;
  final bool reviewed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: reviewed ? const Color(0xFFE7F4FF) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: reviewed
                  ? const Color(0xFF6A97F3)
                  : const Color(0xFF3DB9EE),
              width: 2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: reviewed
                      ? const Color(0xFF3C98CF)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: reviewed
                      ? null
                      : Border.all(color: const Color(0xFF318DB6), width: 2),
                ),
                child: reviewed
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2B5A70),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(
                        item.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6A8998),
                          fontSize: 9.6,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyItemData {
  const _PrivacyItemData(this.title, this.description);

  final String title;
  final String description;
}

const privacyItemsDesignScreen = <_PrivacyItemData>[
  _PrivacyItemData(
    'Use pseudonyms',
    'Use invented names for colleagues, teams, and employers so real identities are not exposed in notes or requests.',
  ),
  _PrivacyItemData(
    'Avoid sensitive material',
    'Do not enter confidential, secret, legally restricted, or commercially sensitive workplace content, screenshots, or messages.',
  ),
  _PrivacyItemData(
    'Politics consultant limits',
    'Treat the politics consultant’s predictions as conditional possibilities, not facts about another person. Review advice using your own judgment and evidence.',
  ),
  _PrivacyItemData(
    'Provider and data consent',
    'Understand what may be sent to service providers and remain in control of what is retained, exported, or permanently deleted.',
  ),
];
