import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../data/audio_service.dart';
import '../../../domain/canvas_item.dart';
import '../../../domain/combine_outcome.dart';
import '../../../domain/game_controller.dart';
import '../../shared/widgets/discovery_dialog.dart';
import 'widgets/game_canvas.dart';
import 'widgets/library_rail.dart';

/// The play surface (canvas + element rail). The persistent bottom toolbar
/// lives in the surrounding shell, not here.
class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  final math.Random _random = math.Random();
  Set<int> _shakingUids = <int>{};
  final Set<int> _vanishingUids = <int>{};
  ({double x, double y})? _flash;
  int _flashToken = 0;
  ({double x, double y, String elementId, int token})? _hint;
  int _hintToken = 0;
  Size _canvasSize = Size.zero;
  String _search = '';
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    // First run only: open the walkthrough once the canvas is on screen, so the
    // player closes it straight onto the board it just described. The intro
    // marks itself as seen however it is dismissed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<GameController>().introSeen) return;
      context.push(AppRoutes.intro);
    });
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final AppLocalizations strings = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.1,
          colors: <Color>[AppColors.nightTop, AppColors.nightDeep],
          stops: <double>[0, 0.7],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: GameCanvas(
                      items: controller.canvasItems,
                      shakingUids: _shakingUids,
                      vanishingUids: _vanishingUids,
                      flash: _flash,
                      hint: _hint,
                      onSpawn: (String id, Offset center, Size size) {
                        final Offset p = _clamp(center, size);
                        final int uid = controller.addToCanvas(id, p.dx, p.dy);
                        _play(Sfx.drop);
                        _resolve(controller.combineNear(uid));
                      },
                      onMove: (int uid, Offset center, Size size) {
                        final Offset p = _clamp(center, size);
                        controller.updatePosition(uid, p.dx, p.dy);
                        // Bring to front now (after the drag) rather than on
                        // drag start, which would rebuild mid-drag and leave a
                        // ghost of the item at its old position.
                        controller.bringToFront(uid);
                        _play(Sfx.drop);
                        _resolve(controller.combineNear(uid));
                      },
                      onInfoItem: (int uid) {
                        final String? id = controller.elementIdOf(uid);
                        if (id != null) _openDetail(id);
                      },
                      onDuplicateItem: _duplicate,
                      onItemVanished: _onItemVanished,
                      onSizeChanged: (Size size) => _canvasSize = size,
                    ),
                  ),
                  _CanvasSearch(
                    searching: _searching,
                    hint: strings.searchElements,
                    onToggle: () => setState(() {
                      _searching = !_searching;
                      if (!_searching) _search = '';
                    }),
                    onChanged: (String v) => setState(() => _search = v),
                  ),
                ],
              ),
            ),
            LibraryRail(
              controller: controller,
              strings: strings,
              search: _search,
              onAdd: _addToCenter,
              onInfo: _openDetail,
              onRemove: controller.removeFromCanvas,
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(String elementId) {
    context.push('${AppRoutes.element}/$elementId');
  }

  /// Double-tap: drop a copy at a random nearby spot,  close, but past the
  /// combine distance so it neither stacks on the original nor auto-combines.
  void _duplicate(int uid) {
    if (_canvasSize == Size.zero) return;
    final GameController controller = context.read<GameController>();
    final CanvasItem? item =
        controller.canvasItems.where((CanvasItem it) => it.uid == uid).firstOrNull;
    if (item == null) return;
    final Offset origin = Offset(item.x, item.y);

    // Try a few random directions; keep the first that lands far enough away
    // (so it isn't too close), falling back to the last near a tight corner.
    Offset target = origin;
    for (int i = 0; i < 8; i++) {
      final double angle = _random.nextDouble() * 2 * math.pi;
      final double distance = 60 + _random.nextDouble() * 45; // 60–105px.
      target = _clamp(
        origin + Offset(math.cos(angle) * distance, math.sin(angle) * distance),
        _canvasSize,
      );
      if ((target - origin).distance >= 58) break;
    }
    // No combineNear here: a fresh duplicate should just sit on the canvas.
    controller.addToCanvas(item.elementId, target.dx, target.dy);
    _play(Sfx.drop);
  }

  void _addToCenter(String elementId) {
    if (_canvasSize == Size.zero) return;
    final GameController controller = context.read<GameController>();
    final double x = _canvasSize.width / 2 + _random.nextDouble() * 70 - 35;
    final double y = _canvasSize.height * 0.45 + _random.nextDouble() * 70 - 35;
    final Offset p = _clamp(Offset(x, y), _canvasSize);
    final int uid = controller.addToCanvas(elementId, p.dx, p.dy);
    _play(Sfx.drop);
    _resolve(controller.combineNear(uid));
  }

  /// Fires a one-shot sound effect through the shared [AudioService] (a no-op
  /// when the player has sound disabled).
  void _play(Sfx sfx) => context.read<AudioService>().playEffect(sfx);

  Offset _clamp(Offset point, Size size) {
    return Offset(
      point.dx.clamp(32.0, size.width - 32),
      point.dy.clamp(32.0, size.height - 32),
    );
  }

  void _resolve(CombineOutcome outcome) {
    switch (outcome) {
      case CombineMerged(:final double x, :final double y, :final bool isNewDiscovery, :final String resultId):
        _showFlash(x, y);
        if (isNewDiscovery) {
          // Celebrate every discovery; mark each 25th with a louder fanfare.
          final int count = context.read<GameController>().discoveredCount;
          _play(count > 0 && count % 25 == 0 ? Sfx.milestone : Sfx.discovery);
          showDiscoveryShowcase(context, <String>[resultId]);
        } else {
          _play(Sfx.combine);
        }
      case CombineHinted(:final double x, :final double y, :final String resultId):
        // The same pair re-mixed: the gentle "blend" rather than a discovery.
        _play(Sfx.combine);
        _showHint(x, y, resultId);
      case CombineReplayed(:final double x, :final double y, :final int uid):
        // A different recipe reached an already-known item: no showcase, but the
        // result is briefly placed on the canvas, then collapses away.
        _play(Sfx.combine);
        _showFlash(x, y);
        _scheduleVanish(uid);
      case CombineRejected(:final int uidA, :final int uidB):
        _play(Sfx.reject);
        _shake(<int>{uidA, uidB});
      case CombineNone():
        break;
    }
  }

  /// After a brief pause, starts the circle-collapse fade on the temporary
  /// result item [uid],  provided it is still on the canvas and hasn't been
  /// dragged or combined away in the meantime.
  void _scheduleVanish(int uid) {
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final GameController controller = context.read<GameController>();
      final bool stillThere =
          controller.canvasItems.any((CanvasItem it) => it.uid == uid);
      if (stillThere) setState(() => _vanishingUids.add(uid));
    });
  }

  /// The collapse finished: drop the item from the canvas for good.
  void _onItemVanished(int uid) {
    context.read<GameController>().removeFromCanvas(uid);
    setState(() => _vanishingUids.remove(uid));
  }

  void _showHint(double x, double y, String elementId) {
    final int token = ++_hintToken;
    setState(() => _hint = (x: x, y: y, elementId: elementId, token: token));
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _hintToken == token) setState(() => _hint = null);
    });
  }

  void _showFlash(double x, double y) {
    final int token = ++_flashToken;
    setState(() => _flash = (x: x, y: y));
    Future<void>.delayed(const Duration(milliseconds: 680), () {
      if (mounted && _flashToken == token) setState(() => _flash = null);
    });
  }

  void _shake(Set<int> uids) {
    setState(() => _shakingUids = uids);
    Future<void>.delayed(const Duration(milliseconds: 460), () {
      if (mounted) setState(() => _shakingUids = <int>{});
    });
  }
}

/// The floating search affordance on the canvas: a magnifier button that
/// expands into a search field filtering the element rail.
class _CanvasSearch extends StatelessWidget {
  const _CanvasSearch({
    required this.searching,
    required this.hint,
    required this.onToggle,
    required this.onChanged,
  });

  final bool searching;
  final String hint;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!searching) {
      return Positioned(
        top: 10,
        right: 10,
        child: _CircleButton(icon: Icons.search_rounded, onTap: onToggle),
      );
    }
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.cocoa.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.search_rounded, size: 18, color: AppColors.mutedBrown),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                autofocus: true,
                onChanged: onChanged,
                cursorColor: AppColors.gold,
                style: AppText.body(size: 14, color: AppColors.cocoa),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: AppText.body(size: 14, color: AppColors.fadedBrown),
                ),
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: const Icon(Icons.close_rounded,
                  size: 18, color: AppColors.mutedBrown),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.cocoa.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.spiceBrown, size: 22),
      ),
    );
  }
}
