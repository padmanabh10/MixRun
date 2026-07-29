import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/element_icon.dart';

/// A looping animation of the core gesture: one element is dragged onto
/// another, the two merge, and the result pops out.
///
/// Purely decorative,  it mimics the canvas rather than driving it, so the
/// walkthrough can show the gesture without a live game underneath.
class DragDemo extends StatefulWidget {
  const DragDemo({
    super.key,
    required this.sourceId,
    required this.targetId,
    required this.resultId,
    required this.sourceLabel,
    required this.targetLabel,
    required this.resultLabel,
  });

  final String sourceId;
  final String targetId;
  final String resultId;
  final String sourceLabel;
  final String targetLabel;
  final String resultLabel;

  @override
  State<DragDemo> createState() => _DragDemoState();
}

class _DragDemoState extends State<DragDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat();

  // Phase boundaries within one loop, as fractions of the whole cycle:
  // settle, drag across, merge, then hold on the result.
  static const double _dragStart = 0.18;
  static const double _dragEnd = 0.55;
  static const double _mergeEnd = 0.68;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double w = constraints.maxWidth;
          const double tile = 86;
          final double y = 34;
          final double leftX = w * 0.5 - tile - 26;
          final double rightX = w * 0.5 + 26;

          return AnimatedBuilder(
            animation: _c,
            builder: (BuildContext context, _) {
              final double t = _c.value;

              // Eased progress of the drag from the left tile to the right one.
              final double drag = t <= _dragStart
                  ? 0
                  : t >= _dragEnd
                      ? 1
                      : Curves.easeInOut.transform(
                          (t - _dragStart) / (_dragEnd - _dragStart),
                        );

              final bool merged = t >= _dragEnd;
              final double mergeT = !merged
                  ? 0
                  : t >= _mergeEnd
                      ? 1
                      : (t - _dragEnd) / (_mergeEnd - _dragEnd);

              final double dragX = leftX + (rightX - leftX) * drag;
              // A small lift as the item is picked up and set down again.
              final double lift = -10 * Curves.easeInOut.transform(
                    1 - (2 * drag - 1).abs(),
                  );

              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  // The stationary target, which fades out as the pair merges.
                  if (!merged || mergeT < 1)
                    Positioned(
                      left: rightX,
                      top: y,
                      child: Opacity(
                        opacity: merged ? 1 - mergeT : 1,
                        child: _Tile(
                          elementId: widget.targetId,
                          label: widget.targetLabel,
                          size: tile,
                          highlight: drag > 0.75 && !merged,
                        ),
                      ),
                    ),

                  // The dragged item.
                  if (!merged)
                    Positioned(
                      left: dragX,
                      top: y + lift,
                      child: _Tile(
                        elementId: widget.sourceId,
                        label: widget.sourceLabel,
                        size: tile,
                        lifted: drag > 0 && drag < 1,
                      ),
                    ),

                  // The result, popping out where the two met.
                  if (merged)
                    Positioned(
                      left: rightX,
                      top: y,
                      child: Transform.scale(
                        scale: 0.6 + 0.4 * Curves.easeOutBack.transform(mergeT),
                        child: Opacity(
                          opacity: mergeT,
                          child: _Tile(
                            elementId: widget.resultId,
                            label: widget.resultLabel,
                            size: tile,
                            glow: true,
                          ),
                        ),
                      ),
                    ),

                  // The fingertip guiding the drag.
                  if (!merged)
                    Positioned(
                      left: dragX + tile * 0.62,
                      top: y + lift + tile * 0.66,
                      child: _Fingertip(pressed: drag > 0 && drag < 1),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.elementId,
    required this.label,
    required this.size,
    this.lifted = false,
    this.highlight = false,
    this.glow = false,
  });

  final String elementId;
  final String label;
  final double size;
  final bool lifted;
  final bool highlight;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: glow
                  ? AppColors.gold.withValues(alpha: 0.7)
                  : highlight
                      ? AppColors.gold.withValues(alpha: 0.5)
                      : AppColors.cocoa.withValues(alpha: 0.08),
              width: glow || highlight ? 2 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: glow
                    ? AppColors.gold.withValues(alpha: 0.35)
                    : AppColors.cocoa.withValues(alpha: lifted ? 0.18 : 0.06),
                blurRadius: lifted || glow ? 20 : 10,
                offset: Offset(0, lifted ? 8 : 4),
              ),
            ],
          ),
          child: ElementIcon(elementId: elementId, size: size * 0.62),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: size + 16,
          child: Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(
              size: 11.5,
              weight: FontWeight.w600,
              color: glow ? AppColors.spiceBrown : AppColors.mutedBrown,
            ),
          ),
        ),
      ],
    );
  }
}

/// The translucent circle standing in for the player's fingertip.
class _Fingertip extends StatelessWidget {
  const _Fingertip({required this.pressed});

  final bool pressed;

  @override
  Widget build(BuildContext context) {
    final double size = pressed ? 30 : 26;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cocoa.withValues(alpha: pressed ? 0.22 : 0.14),
        border: Border.all(color: AppColors.cocoa.withValues(alpha: 0.28)),
      ),
    );
  }
}
