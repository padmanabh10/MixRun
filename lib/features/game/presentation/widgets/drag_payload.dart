/// Payload carried by a drag on the game screen.
///
/// A [SpawnDrag] originates from the element library and creates a new canvas
/// item; a [MoveDrag] repositions an item already on the canvas.
sealed class DragPayload {
  const DragPayload();
}

class SpawnDrag extends DragPayload {
  const SpawnDrag(this.elementId);

  final String elementId;
}

class MoveDrag extends DragPayload {
  const MoveDrag(this.uid);

  final int uid;
}
