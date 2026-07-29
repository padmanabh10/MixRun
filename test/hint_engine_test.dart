import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mixrun/data/progress_repository.dart';
import 'package:mixrun/domain/game_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<GameController> freshController() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ProgressRepository repo = await ProgressRepository.create();
    return GameController(repo);
  }

  test('requestHint adds an active hint and consumes a daily allowance',
      () async {
    final GameController c = await freshController();
    expect(c.activeHintCount, 0);
    expect(c.hintsRemainingToday, GameController.dailyHintLimit);

    final String? id = c.requestHint();
    expect(id, isNotNull);
    expect(c.activeHints, contains(id));
    expect(c.activeHintCount, 1);
    expect(c.hintsRemainingToday, GameController.dailyHintLimit - 1);
  });

  test('the daily limit blocks further hints once exhausted', () async {
    final GameController c = await freshController();
    // Starters can make enough elements to exhaust the daily limit.
    expect(c.hintCandidates.length,
        greaterThanOrEqualTo(GameController.dailyHintLimit));

    for (int i = 0; i < GameController.dailyHintLimit; i++) {
      expect(c.requestHint(), isNotNull);
    }
    expect(c.hintsRemainingToday, 0);
    expect(c.canRequestHint, isFalse);
    expect(c.requestHint(), isNull);
    expect(c.activeHintCount, GameController.dailyHintLimit);
  });

  test('hints never repeat an already-active element', () async {
    final GameController c = await freshController();
    final int n = math.min(
        GameController.dailyHintLimit, c.hintCandidates.length);
    for (int i = 0; i < n; i++) {
      c.requestHint();
    }
    expect(c.activeHints.toSet().length, c.activeHints.length);
  });

  test('ad and hint state survives a reload', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ProgressRepository repo = await ProgressRepository.create();
    final GameController c = GameController(repo);

    c.recordAdWatched();
    c.recordAdWatched();
    final String? hint = c.requestHint();
    expect(hint, isNotNull);

    // A new controller over the same store should see the persisted state.
    final GameController reloaded = GameController(repo);
    expect(reloaded.adsWatched, 2);
    expect(reloaded.activeHints, contains(hint));
    expect(reloaded.hintsRemainingToday, GameController.dailyHintLimit - 1);
  });
}
