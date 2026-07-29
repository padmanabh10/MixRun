import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../data/audio_service.dart';
import '../../../data/game_levels.dart';
import '../../../data/models/game_level.dart';
import '../../../domain/encyclopedia_filter.dart';
import '../../../domain/game_controller.dart';
import '../../shared/widgets/light_back_button.dart';
import '../../shared/widgets/parchment_scaffold.dart';

/// The Journey: the player's progress laid out across a relief map of India.
///
/// The map is zoomable and pannable,  each level is a distinct medallion pinned
/// to a real region of the country, and the player drags the map to seek out the
/// stops that come next. Level 1, "Base Level", holds the core catalog and sits
/// unlocked; the five themed stops after it,  States & UTs, History & Sites,
/// Culture & Cuisine, Dance & Local Art, and Heroes & Kings,  are placed around
/// the landmass and each unlocks once the level before it is fully discovered.
class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key});

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  /// Natural pixel size of `assets/images/india.png`, used only for its ratio.
  static const double _mapAspect = 1870 / 841; // height / width

  final TransformationController _transform = TransformationController();
  bool _centeredOnBase = false;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  /// Map placement for each stop, in the same order as [GameLevels.all]: the
  /// Base Level first, then the five themed levels. Positions are normalized
  /// (0..1) coordinates pinned to regions of the India map.
  static const List<_StopStyle> _styles = <_StopStyle>[
    _StopStyle(Offset(0.25, 0.23), Icons.auto_awesome_rounded, AppColors.gold),
    _StopStyle(Offset(0.13, 0.37), Icons.map_rounded, AppColors.orange),
    _StopStyle(Offset(0.43, 0.38), Icons.account_balance_rounded, AppColors.brick),
    _StopStyle(Offset(0.88, 0.35), Icons.restaurant_rounded, AppColors.teal),
    _StopStyle(Offset(0.50, 0.50), Icons.palette_rounded, AppColors.gold),
    _StopStyle(Offset(0.33, 0.70), Icons.shield_rounded, AppColors.brick),
  ];

  /// How much of a stop must be discovered before the next one unlocks. A
  /// themed level opens once the level before it reaches this fraction of its
  /// elements, so the trail lights up region by region without demanding a
  /// full 100% clear of every earlier stop. Shared with the Stats page.
  static const double _unlockFraction = GameController.levelUnlockFraction;

  /// The ordered stops of the journey. The Base Level is always unlocked; each
  /// themed level after it stays locked until the stop before it is at least
  /// [_unlockFraction] discovered.
  List<_MapStop> _stops(GameController controller) {
    final List<_MapStop> stops = <_MapStop>[];
    bool prevUnlocked = true; // The Base Level opens the journey unlocked.
    for (int i = 0; i < GameLevels.all.length; i++) {
      final GameLevel level = GameLevels.all[i];
      final _StopStyle style = _styles[i];
      final int discovered =
          level.elementIds.where(controller.isDiscovered).length;
      final int total = level.elementIds.length;
      stops.add(_MapStop(
        title: level.titleEn,
        position: style.position,
        icon: style.icon,
        accent: style.accent,
        level: level,
        discovered: discovered,
        total: total,
        comingSoon: !prevUnlocked,
      ));
      // Enough of this stop is done to unlock the next one.
      prevUnlocked = total > 0 && discovered >= (total * _unlockFraction).ceil();
    }
    return stops;
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final AppLocalizations strings = AppLocalizations.of(context);
    final List<_MapStop> stops = _stops(controller);
    final int percent = (controller.progress * 100).round();

    return ParchmentScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: <Widget>[
                const LightBackButton(),
                const SizedBox(width: 12),
                Text(
                  strings.yourJourney,
                  style: AppText.display(
                    size: 24,
                    weight: FontWeight.w800,
                    color: AppColors.cocoa,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryChip(
                    icon: Icons.auto_awesome_rounded,
                    label: strings.journeyDiscoveries,
                    value: '${controller.discoveredCount}',
                    tinted: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryChip(
                    icon: Icons.flag_rounded,
                    label: strings.journeyCompletion,
                    value: '$percent%',
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Row(
              children: <Widget>[
                Icon(Icons.pinch_rounded, size: 15, color: AppColors.mutedBrown),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Pinch to zoom · drag across India to find the next levels',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedBrown,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.nightDeep,
                    border: Border.all(
                      color: AppColors.cocoa.withValues(alpha: 0.07),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints c) {
                      // Draw the map larger than the viewport so there is always
                      // room to pan around and hunt down distant stops.
                      final double mapW = math.max(c.maxWidth, 360) * 1.4;
                      final double mapH = mapW * _mapAspect;
                      _maybeCenterOnBase(stops.first, mapW, mapH, c);
                      return InteractiveViewer(
                        transformationController: _transform,
                        constrained: false,
                        minScale: 1.0,
                        maxScale: 4.0,
                        // No margin: panning stops at the image edges, so the
                        // player never drags into blank space around the map.
                        boundaryMargin: EdgeInsets.zero,
                        child: SizedBox(
                          width: mapW,
                          height: mapH,
                          child: Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/images/india.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _TrailPainter(
                                    stops: stops,
                                    mapW: mapW,
                                    mapH: mapH,
                                  ),
                                ),
                              ),
                              for (final _MapStop stop in stops)
                                Positioned(
                                  left: stop.position.dx * mapW - _StopNode.width / 2,
                                  top: stop.position.dy * mapH - _StopNode.circle / 2,
                                  child: _StopNode(
                                    stop: stop,
                                    onOpen: stop.level != null && !stop.comingSoon
                                        ? () => _openLevel(
                                            context, controller, stop.level!)
                                        : null,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Zoom applied when the map first opens, focused on the Base Level.
  static const double _initialScale = 2.0;

  /// Positions and zooms the viewport onto the Base Level the first time the map
  /// is laid out, so the player starts zoomed in on the unlocked stop rather
  /// than a far map corner. The translation is clamped so the image still fills
  /// the viewport,  no blank margins creep in.
  void _maybeCenterOnBase(
    _MapStop base,
    double mapW,
    double mapH,
    BoxConstraints c,
  ) {
    if (_centeredOnBase) return;
    _centeredOnBase = true;
    const double scale = _initialScale;
    final double vw = c.maxWidth;
    final double vh = c.maxHeight;
    final double bx = base.position.dx * mapW;
    final double by = base.position.dy * mapH;
    final double tx =
        (vw / 2 - scale * bx).clamp(vw - scale * mapW, 0.0).toDouble();
    final double ty =
        (vh / 2 - scale * by).clamp(vh - scale * mapH, 0.0).toDouble();
    final Matrix4 m = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, tx)
      ..setEntry(1, 3, ty);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _transform.value = m;
    });
  }

  /// Opens the Encyclopedia narrowed to [level],  its category, or the whole
  /// catalog for a level that maps to no single category.
  void _openLevel(
    BuildContext context,
    GameController controller,
    GameLevel level,
  ) {
    context.read<AudioService>().playEffect(Sfx.button);
    controller.setEncyclopediaFilter(LevelFilter(level.id));
    context.go(AppRoutes.encyclopedia);
  }
}

/// Fixed map presentation for a stop,  where it sits and how its medallion
/// looks,  kept separate from the live [GameLevel] it renders.
class _StopStyle {
  const _StopStyle(this.position, this.icon, this.accent);

  final Offset position;
  final IconData icon;
  final Color accent;
}

/// One stop pinned to the India map: its region title, normalized map position,
/// medallion icon and accent. A stop either wraps a real [level] or is an
/// upcoming region ([comingSoon]).
class _MapStop {
  const _MapStop({
    required this.title,
    required this.position,
    required this.icon,
    required this.accent,
    this.level,
    this.discovered = 0,
    this.total = 0,
    this.comingSoon = false,
  });

  final String title;

  /// Position on the map in normalized (0..1) coordinates from the top-left.
  final Offset position;
  final IconData icon;
  final Color accent;
  final GameLevel? level;
  final int discovered;
  final int total;
  final bool comingSoon;

  bool get complete => total > 0 && discovered == total;
}

/// A medallion marking a stop on the map: a ringed icon disc with the region
/// name and, for the live level, a discovered/total caption. Locked upcoming
/// stops wear a subdued look and a small lock.
class _StopNode extends StatelessWidget {
  const _StopNode({required this.stop, required this.onOpen});

  final _MapStop stop;
  final VoidCallback? onOpen;

  static const double circle = 54;
  static const double width = 128;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final bool locked = stop.comingSoon;
    final Color ring = locked
        ? AppColors.lockedBrown
        : stop.complete
            ? AppColors.metalGold
            : stop.accent;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(circle),
              child: Container(
                width: circle,
                height: circle,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: locked ? AppColors.nightDeep : Colors.white,
                  border: Border.all(color: ring, width: 2.5),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: ring.withValues(alpha: locked ? 0.12 : 0.32),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  locked ? Icons.lock_rounded : stop.icon,
                  size: 26,
                  color: locked ? AppColors.lockedBrown : stop.accent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          _Pill(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  stop.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppText.display(
                    size: 12.5,
                    weight: FontWeight.w800,
                    color: locked ? AppColors.mutedBrown : AppColors.cocoa,
                  ),
                ),
                Text(
                  locked
                      ? 'Locked'
                      : '${stop.discovered} / ${stop.total} ${strings.discovered}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(
                    size: 10.5,
                    color: locked ? AppColors.fadedBrown : AppColors.spiceBrown,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The small rounded name plate sitting beneath a map medallion.
class _Pill extends StatelessWidget {
  const _Pill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cocoa.withValues(alpha: 0.08)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// A compact headline figure in a rounded pill: the two summary stats above the
/// map (discoveries so far and overall completion).
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    this.tinted = false,
  });

  final IconData icon;
  final String label;
  final String value;

  /// The first chip wears a soft saffron tint to anchor the pair.
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: tinted ? AppColors.gold.withValues(alpha: 0.12) : Colors.white,
        border: Border.all(
          color: tinted
              ? AppColors.gold.withValues(alpha: 0.3)
              : AppColors.cocoa.withValues(alpha: 0.07),
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 22, color: AppColors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(size: 11, color: AppColors.mutedBrown),
                ),
                Text(
                  value,
                  style: AppText.display(
                    size: 20,
                    weight: FontWeight.w800,
                    color: AppColors.cocoa,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lays a run of small dots along a smooth curve threading every stop in order,
/// so the medallions read as one continuous winding trail across the country.
///
/// The curve is a Catmull-Rom spline (each leg a cubic Bézier that passes
/// through its two endpoint stops), so the path flows on through each node
/// rather than kinking at it.
class _TrailPainter extends CustomPainter {
  _TrailPainter({
    required this.stops,
    required this.mapW,
    required this.mapH,
  });

  final List<_MapStop> stops;
  final double mapW;
  final double mapH;

  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> pts = <Offset>[
      for (final _MapStop s in stops)
        Offset(s.position.dx * mapW, s.position.dy * mapH),
    ];
    if (pts.length < 2) return;

    // Trim each leg near its endpoints so dots clear the medallion discs, and
    // stamp a dot every [step] pixels along the leg's curve.
    const double trim = 28;
    const double step = 12;

    for (int i = 0; i < pts.length - 1; i++) {
      // Neighbour points (clamped at the ends) shape the Catmull-Rom tangents.
      final Offset p0 = pts[i == 0 ? 0 : i - 1];
      final Offset p1 = pts[i];
      final Offset p2 = pts[i + 1];
      final Offset p3 = pts[i + 2 >= pts.length ? pts.length - 1 : i + 2];
      // Catmull-Rom -> cubic Bézier control points for the p1..p2 leg.
      final Offset c1 = p1 + (p2 - p0) / 6;
      final Offset c2 = p2 - (p3 - p1) / 6;

      final Path leg = Path()
        ..moveTo(p1.dx, p1.dy)
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);

      // Every leg is a visible saffron dotted line so the whole chain reads as
      // one connected trail; the leg leaving an unlocked stop glows a touch
      // brighter to mark where the player is now.
      final bool active = !stops[i].comingSoon;
      final Paint dot = Paint()
        ..color = AppColors.gold.withValues(alpha: active ? 0.8 : 0.5);

      for (final metric in leg.computeMetrics()) {
        for (double d = trim; d < metric.length - trim; d += step) {
          final tangent = metric.getTangentForOffset(d);
          if (tangent != null) canvas.drawCircle(tangent.position, 2.4, dot);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) =>
      old.stops != stops || old.mapW != mapW || old.mapH != mapH;
}
