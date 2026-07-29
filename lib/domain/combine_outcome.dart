/// The result of attempting to combine a canvas item with its nearest neighbor.
sealed class CombineOutcome {
  const CombineOutcome();
}

/// No neighbor was close enough to attempt a combination.
class CombineNone extends CombineOutcome {
  const CombineNone();
}

/// Two items met but no recipe matched; the UI should shake them.
class CombineRejected extends CombineOutcome {
  const CombineRejected(this.uidA, this.uidB);

  final int uidA;
  final int uidB;
}

/// A recipe the player has already used was performed again, and its result is
/// already discovered, so nothing is produced,  the UI floats a translucent
/// hint of [resultId] instead, and the ingredients stay put.
class CombineHinted extends CombineOutcome {
  const CombineHinted({
    required this.resultId,
    required this.x,
    required this.y,
  });

  final String resultId;
  final double x;
  final double y;
}

/// A *different* recipe produced an item the player had already discovered.
///
/// There's no showcase (it isn't a new find) and the ingredients stay put, but
/// unlike [CombineHinted] the result is genuinely placed on the canvas as [uid]
/// so the player sees the new path pay off. The view fades that item out again
/// after a few seconds with a circle-collapse animation.
class CombineReplayed extends CombineOutcome {
  const CombineReplayed({
    required this.resultId,
    required this.x,
    required this.y,
    required this.uid,
  });

  final String resultId;
  final double x;
  final double y;

  /// The uid of the temporary result item placed on the canvas.
  final int uid;
}

/// A recipe matched and produced a new element on the canvas.
class CombineMerged extends CombineOutcome {
  const CombineMerged({
    required this.resultId,
    required this.x,
    required this.y,
    required this.isNewDiscovery,
  });

  final String resultId;
  final double x;
  final double y;
  final bool isNewDiscovery;
}
