import 'package:flutter/material.dart';

class RelationshipQualityBar extends StatefulWidget {
  const RelationshipQualityBar({
    super.key,
    required this.score,
    required this.keyPrefix,
    this.onChanged,
    this.showLabels = true,
  });

  final double score;
  final String keyPrefix;
  final ValueChanged<double>? onChanged;
  final bool showLabels;

  @override
  State<RelationshipQualityBar> createState() => _RelationshipQualityBarState();
}

class _RelationshipQualityBarState extends State<RelationshipQualityBar> {
  late double displayedScore = widget.score.clamp(0.0, 1.0);
  bool dragging = false;

  @override
  void didUpdateWidget(covariant RelationshipQualityBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!dragging && oldWidget.score != widget.score) {
      displayedScore = widget.score.clamp(0.0, 1.0);
    }
  }

  double _scoreForPosition(double dx, double width) {
    const indicatorSize = 22.0;
    return ((dx - indicatorSize / 2) / (width - indicatorSize)).clamp(0.0, 1.0);
  }

  void _updateFromPosition(double dx, double width) {
    final value = _scoreForPosition(dx, width);
    setState(() => displayedScore = value);
    widget.onChanged?.call(value);
  }

  void _snapToNearestChoice() {
    final snapped = (displayedScore * 4).round() / 4;
    setState(() {
      dragging = false;
      displayedScore = snapped;
    });
    widget.onChanged?.call(snapped);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('${widget.keyPrefix}-quality'),
      children: [
        if (widget.showLabels) ...[
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Very Bad', style: _scaleLabelStyle),
              Text('Bad', style: _scaleLabelStyle),
              Text('Neutral', style: _scaleLabelStyle),
              Text('Good', style: _scaleLabelStyle),
              Text('Very Good', style: _scaleLabelStyle),
            ],
          ),
          const SizedBox(height: 4),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            const indicatorSize = 22.0;
            final indicatorLeft =
                (constraints.maxWidth - indicatorSize) * displayedScore;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: widget.onChanged == null
                  ? null
                  : (details) {
                      _updateFromPosition(
                        details.localPosition.dx,
                        constraints.maxWidth,
                      );
                      _snapToNearestChoice();
                    },
              onHorizontalDragStart: widget.onChanged == null
                  ? null
                  : (details) {
                      dragging = true;
                      _updateFromPosition(
                        details.localPosition.dx,
                        constraints.maxWidth,
                      );
                    },
              onHorizontalDragUpdate: widget.onChanged == null
                  ? null
                  : (details) => _updateFromPosition(
                      details.localPosition.dx,
                      constraints.maxWidth,
                    ),
              onHorizontalDragEnd: widget.onChanged == null
                  ? null
                  : (_) => _snapToNearestChoice(),
              onHorizontalDragCancel: widget.onChanged == null
                  ? null
                  : _snapToNearestChoice,
              child: SizedBox(
                height: indicatorSize,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      key: ValueKey('${widget.keyPrefix}-gradient'),
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF276F9E),
                            Color(0xFFA9DFF4),
                            Color(0xFFFFFFFF),
                            Color(0xFFDCCFFF),
                            Color(0xFF806DE2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF477892,
                            ).withValues(alpha: 0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: indicatorLeft,
                      child: Container(
                        key: ValueKey('${widget.keyPrefix}-indicator'),
                        width: indicatorSize,
                        height: indicatorSize,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF356A84),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF245672,
                              ).withValues(alpha: 0.25),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.people_alt_rounded,
                          size: 12,
                          color: Color(0xFF356A84),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

const _scaleLabelStyle = TextStyle(
  color: Color(0xFF4E7890),
  fontSize: 6.5,
  fontWeight: FontWeight.w900,
);
