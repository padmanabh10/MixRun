import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/element_icon.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../../data/audio_service.dart';
import '../../../../domain/game_controller.dart';
import 'drag_ghost.dart';
import 'drag_payload.dart';

/// The right-hand element list on the play screen.
///
/// Discovered elements are listed alphabetically and the list scrolls freely
/// (only an element's icon starts a drag, so vertical drags elsewhere scroll).
/// Tapping a row drops it on the canvas; long-press opens its detail. Dropping
/// a canvas item back onto the rail removes it from the canvas.
class LibraryRail extends StatelessWidget {
  const LibraryRail({
    super.key,
    required this.controller,
    required this.strings,
    required this.search,
    required this.onAdd,
    required this.onInfo,
    required this.onRemove,
  });

  final GameController controller;
  final AppLocalizations strings;
  final String search;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onInfo;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final List<String> ids = controller.libraryIds(search);
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (DragTargetDetails<DragPayload> d) =>
          d.data is MoveDrag,
      onAcceptWithDetails: (DragTargetDetails<DragPayload> d) {
        if (d.data case MoveDrag(:final int uid)) onRemove(uid);
      },
      builder: (context, candidate, __) {
        final bool removing = candidate.isNotEmpty;
        return Container(
          width: 150,
          decoration: BoxDecoration(
            color: removing
                ? AppColors.brick.withValues(alpha: 0.10)
                : AppColors.libraryPanel,
            border: Border(
              left: BorderSide(
                color: removing
                    ? AppColors.brick.withValues(alpha: 0.5)
                    : AppColors.cocoa.withValues(alpha: 0.07),
                width: removing ? 2 : 1,
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.cocoa.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(-6, 0),
              ),
            ],
          ),
          child: ids.isEmpty
              ? _Empty(strings: strings)
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(6, 8, 6, 8 + bottomInset),
                  itemCount: ids.length,
                  itemBuilder: (context, index) => _RailRow(
                    elementId: ids[index],
                    name: controller.elementName(ids[index]),
                    onAdd: () => onAdd(ids[index]),
                    onInfo: () => onInfo(ids[index]),
                  ),
                ),
        );
      },
    );
  }
}

class _RailRow extends StatelessWidget {
  const _RailRow({
    required this.elementId,
    required this.name,
    required this.onAdd,
    required this.onInfo,
  });

  final String elementId;
  final String name;
  final VoidCallback onAdd;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onAdd,
        onLongPress: onInfo,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          child: Row(
            children: <Widget>[
              // Only the icon starts a drag; the rest of the row lets the
              // list scroll and taps add the element.
              Draggable<DragPayload>(
                data: SpawnDrag(elementId),
                feedback: DragGhost(elementId: elementId, size: 48),
                onDragStarted: () =>
                    context.read<AudioService>().playEffect(Sfx.pickup),
                child: ElementIcon(elementId: elementId, size: 48),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.cocoa,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          strings.searchElements,
          textAlign: TextAlign.center,
          style: AppText.body(size: 12, color: AppColors.fadedBrown),
        ),
      ),
    );
  }
}
