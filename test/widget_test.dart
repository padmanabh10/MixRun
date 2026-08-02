import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mixrun/app.dart';
import 'package:mixrun/core/router/app_router.dart';
import 'package:mixrun/data/app_update_repository.dart';
import 'package:mixrun/data/audio_service.dart';
import 'package:mixrun/data/progress_repository.dart';
import 'package:mixrun/data/rewarded_ad_service.dart';
import 'package:mixrun/domain/account_controller.dart';
import 'package:mixrun/domain/game_controller.dart';

/// Preferences for a player who has already seen the first-run walkthrough.
///
/// The in-game tests below are about the game, not the intro; without this the
/// walkthrough opens over the canvas and hides the toolbar they assert on.
const Map<String, Object> _returningPlayer = <String, Object>{
  'mixrun.introSeen': true,
};

/// An update repository with no Firestore behind it and nothing cached, so the
/// check finds no release and no prompt covers the screens under test.
Future<AppUpdateRepository> _offlineUpdates() async => AppUpdateRepository(
      prefs: await SharedPreferences.getInstance(),
      currentVersionCode: 1,
    );

void main() {
  testWidgets('home screen shows only branding and the play button',
      (tester) async {
    // Use a phone-sized surface so the portrait layout fits as designed.
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(_returningPlayer);
    final ProgressRepository repository = await ProgressRepository.create();

    final GameController game = GameController(repository);
    await tester.pumpWidget(
      MixRunApp(
        controller: game,
        account: AccountController(game: game, available: false),
        // The tests never open the Hints screen, so the ad service stays idle.
        rewardedAds: RewardedAdService(),
        audio: AudioService(),
        updates: await _offlineUpdates(),
      ),
    );
    // Advance past the splash screen's hold before it routes to home.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Play'), findsOneWidget);
    // The secondary destinations now live in the in-game toolbar, not home.
    expect(find.text('Encyclopedia'), findsNothing);
    expect(find.text('Stats'), findsNothing);
    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('toolbar persists across sections and system back reaches canvas',
      (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(_returningPlayer);
    final ProgressRepository repository = await ProgressRepository.create();

    final GameController game = GameController(repository);
    await tester.pumpWidget(
      MixRunApp(
        controller: game,
        account: AccountController(game: game, available: false),
        // The tests never open the Hints screen, so the ad service stays idle.
        rewardedAds: RewardedAdService(),
        audio: AudioService(),
        updates: await _offlineUpdates(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Enter the game from home.
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    // Canvas active: the rail lists starter elements and the toolbar is shown
    // (Encyclopedia is a toolbar button; there is no "Mix" label anymore).
    expect(find.text('Encyclopedia'), findsOneWidget);
    expect(find.text('Earth'), findsWidgets);

    // Open Stats from the toolbar,  its content shows and the toolbar persists.
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Discovered items'), findsOneWidget);
    expect(find.text('Encyclopedia'), findsOneWidget);

    // The phone's back button returns to the canvas, not the home screen.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discovered items'), findsNothing);
    expect(find.text('Earth'), findsWidgets);
    expect(find.text('Play'), findsNothing); // not the home screen
  });

  testWidgets('the intro runs for a new player and never again', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // A brand-new install: nothing stored at all.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ProgressRepository repository = await ProgressRepository.create();
    expect(repository.introSeen, isFalse);

    final GameController game = GameController(repository);
    await tester.pumpWidget(
      MixRunApp(
        controller: game,
        account: AccountController(game: game, available: false),
        rewardedAds: RewardedAdService(),
        audio: AudioService(),
        updates: await _offlineUpdates(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));

    // Reach the canvas the way a player does. The router is a shared singleton,
    // so start from home explicitly,  that disposes any canvas a previous test
    // left mounted, and tapping Play builds a fresh one whose first frame is
    // what triggers the walkthrough.
    AppRouter.router.go(AppRoutes.home);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play'));

    // The drag demo loops forever, so settle in fixed steps rather than
    // pumpAndSettle (which would never return once the intro is on screen).
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    // The walkthrough opened over the canvas.
    expect(find.text('Welcome to MixRun'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    // Skipping closes it and records that it has been seen.
    await tester.tap(find.text('Skip'));
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.text('Welcome to MixRun'), findsNothing);
    expect(game.introSeen, isTrue);
    expect(repository.introSeen, isTrue);

    // Returning to the canvas does not bring it back.
    AppRouter.router.go(AppRoutes.stats);
    await tester.pumpAndSettle();
    AppRouter.router.go(AppRoutes.game);
    await tester.pumpAndSettle();
    expect(find.text('Welcome to MixRun'), findsNothing);
    expect(find.text('Encyclopedia'), findsOneWidget);
  });

  testWidgets('system back from the canvas asks to confirm before exiting',
      (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(_returningPlayer);
    final ProgressRepository repository = await ProgressRepository.create();

    final GameController game = GameController(repository);
    await tester.pumpWidget(
      MixRunApp(
        controller: game,
        account: AccountController(game: game, available: false),
        rewardedAds: RewardedAdService(),
        audio: AudioService(),
        updates: await _offlineUpdates(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Land on the canvas deterministically (the router is a shared singleton,
    // so prior tests may leave it elsewhere).
    AppRouter.router.go(AppRoutes.game);
    await tester.pumpAndSettle();
    expect(find.text('Earth'), findsWidgets);

    // Back on the canvas opens the exit overlay instead of leaving immediately.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Exit game?'), findsOneWidget);
    expect(find.text('Do you want to exit the game?'), findsOneWidget);

    // Choosing "Stay" dismisses the overlay and keeps the player on the canvas.
    await tester.tap(find.text('Stay'));
    await tester.pumpAndSettle();
    expect(find.text('Exit game?'), findsNothing);
    expect(find.text('Earth'), findsWidgets);
  });
}
