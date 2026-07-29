import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/audio_service.dart';
import '../../../../domain/canvas_item.dart';
import 'canvas_item_view.dart';
import 'drag_ghost.dart';
import 'drag_payload.dart';
import 'result_hint.dart';
import 'success_flash.dart';

/// The play surface where elements are dropped, dragged and combined.
///
/// Items rest wherever they are placed,  nothing snaps or re-arranges. Reports
/// drop and tap intents to the parent screen, which owns the combine logic,
/// discovery dialogs and feedback animations.
class GameCanvas extends StatelessWidget {
  const GameCanvas({
    super.key,
    required this.items,
    required this.shakingUids,
    required this.vanishingUids,
    required this.flash,
    required this.hint,
    required this.onSpawn,
    required this.onMove,
    required this.onInfoItem,
    required this.onDuplicateItem,
    required this.onItemVanished,
    required this.onSizeChanged,
  });

  final List<CanvasItem> items;
  final Set<int> shakingUids;

  /// Uids currently playing the circle-collapse fade before being removed.
  final Set<int> vanishingUids;
  final ({double x, double y})? flash;

  /// A translucent result to float up where an already-known pair was re-mixed.
  final ({double x, double y, String elementId, int token})? hint;
  final void Function(String elementId, Offset center, Size size) onSpawn;
  final void Function(int uid, Offset center, Size size) onMove;

  /// Opens the element's detail page (triggered by a long-press).
  final ValueChanged<int> onInfoItem;

  /// Duplicates the item nearby (triggered by a double-tap).
  final ValueChanged<int> onDuplicateItem;

  /// Reports that a vanishing item finished its collapse and can be removed.
  final ValueChanged<int> onItemVanished;
  final ValueChanged<Size> onSizeChanged;

  @override
  Widget build(BuildContext context) {
    final GlobalKey canvasKey = GlobalKey();
    return Container(
      margin: const EdgeInsets.fromLTRB(2, 4, 6, 6),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const RadialGradient(
          center: Alignment(0, -0.2),
          radius: 0.9,
          colors: <Color>[Color(0x14FFFFFF), Color(0x0A2B2D6E)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final Size size = constraints.biggest;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => onSizeChanged(size),
          );
          return DragTarget<DragPayload>(
            onAcceptWithDetails: (DragTargetDetails<DragPayload> details) {
              final RenderBox? box =
                  canvasKey.currentContext?.findRenderObject() as RenderBox?;
              if (box == null) return;
              // details.offset is the global top-left of the dragged ghost;
              // shift by half the footprint so the item's centre lands exactly
              // where the ghost was, rather than up-left of it.
              const Size fp = CanvasItemView.footprint;
              final Offset local = box.globalToLocal(details.offset) +
                  Offset(fp.width / 2, fp.height / 2);
              switch (details.data) {
                case SpawnDrag(:final String elementId):
                  onSpawn(elementId, local, size);
                case MoveDrag(:final int uid):
                  onMove(uid, local, size);
              }
            },
            builder: (context, _, __) {
              return Stack(
                key: canvasKey,
                children: <Widget>[
                  // A full-size hit area so empty regions accept drops.
                  const Positioned.fill(child: ColoredBox(color: Colors.transparent)),
                  for (final CanvasItem item in items) _positioned(context, item),
                  if (flash != null)
                    Positioned(
                      left: flash!.x - 45,
                      top: flash!.y - 45,
                      child: const SuccessFlash(),
                    ),
                  if (hint != null)
                    Positioned(
                      left: hint!.x - 32,
                      top: hint!.y - 64,
                      child: ResultHint(
                        key: ValueKey<int>(hint!.token),
                        elementId: hint!.elementId,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _positioned(BuildContext context, CanvasItem item) {
    const Size fp = CanvasItemView.footprint;
    final bool vanishing = vanishingUids.contains(item.uid);
    final Widget view = CanvasItemView(
      elementId: item.elementId,
      shaking: shakingUids.contains(item.uid),
      vanishing: vanishing,
      onVanished: () => onItemVanished(item.uid),
    );
    return Positioned(
      // A stable key per item so reordering the stack mid-drag (bringToFront)
      // keeps each Draggable's identity,  otherwise the "hidden while dragging"
      // placeholder lands on the wrong item and the original stays visible.
      key: ValueKey<int>(item.uid),
      left: item.x - fp.width / 2,
      top: item.y - fp.height / 2,
      child: Draggable<DragPayload>(
        data: MoveDrag(item.uid),
        feedback: DragGhost(
          elementId: item.elementId,
          size: CanvasItemView.footprint.width,
        ),
        onDragStarted: () =>
            context.read<AudioService>().playEffect(Sfx.pickup),
        childWhenDragging: const SizedBox.shrink(),
        child: GestureDetector(
          // Single tap does nothing; hold for info, double-tap to duplicate.
          onLongPress: () => onInfoItem(item.uid),
          onDoubleTap: () => onDuplicateItem(item.uid),
          child: view,
        ),
      ),
    );
  }
}
