/// A single element instance placed on the play canvas.
///
/// [uid] is unique per placement (the same element id can appear many times);
/// [x] and [y] are pixel offsets within the canvas, measured to the item's
/// center.
class CanvasItem {
  const CanvasItem({
    required this.uid,
    required this.elementId,
    required this.x,
    required this.y,
  });

  final int uid;
  final String elementId;
  final double x;
  final double y;

  CanvasItem copyWith({double? x, double? y}) => CanvasItem(
        uid: uid,
        elementId: elementId,
        x: x ?? this.x,
        y: y ?? this.y,
      );
}
