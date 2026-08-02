import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'data/app_update_repository.dart';
import 'data/audio_service.dart';
import 'data/auth_service.dart';
import 'data/cloud_progress_repository.dart';
import 'data/link_overrides_repository.dart';
import 'data/progress_repository.dart';
import 'data/rewarded_ad_service.dart';
import 'domain/account_controller.dart';
import 'domain/game_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase only initializes once google-services.json is in place; until then
  // the app runs fully offline with account features disabled.
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }

  // While developing against the real ad unit, register your physical device
  // as a test device so AdMob serves *test* creatives you can safely tap.
  // Tapping a real ad on your own app is "invalid traffic" and can get the
  // AdMob account suspended.
  //
  // Device ids are personal to a handset, so they are passed in at build time
  // rather than committed:
  //   flutter run --dart-define=ADMOB_TEST_DEVICE_IDS=HASH1,HASH2
  //
  // To find your device's id: run the app once, open a hint, and look in the
  // console/logcat for a line like:
  //   I/Ads: Use RequestConfiguration.Builder().setTestDeviceIds(
  //       Arrays.asList("33BE2250B43518CCDA7DE426D04EE231"))
  //       to get test ads on this device.
  // With nothing defined (the default, and what release builds ship) no device
  // is registered and AdMob serves live ads.
  const String rawTestDeviceIds =
      String.fromEnvironment('ADMOB_TEST_DEVICE_IDS');
  final List<String> testDeviceIds = rawTestDeviceIds
      .split(',')
      .map((String id) => id.trim())
      .where((String id) => id.isNotEmpty)
      .toList();
  if (testDeviceIds.isNotEmpty) {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: testDeviceIds),
    );
  }

  // Initialize the Google Mobile Ads SDK and warm up the first rewarded ad so
  // it's ready by the time the player opens the Hints screen.
  unawaited(MobileAds.instance.initialize());
  final RewardedAdService rewardedAds = RewardedAdService()..load();

  final ProgressRepository repository = await ProgressRepository.create();
  final GameController game = GameController(repository);

  // "Learn more" links can be corrected server-side without shipping an update.
  // Apply the cached corrections immediately (so they hold offline and are in
  // place before the first frame), then refresh in the background when stale.
  final LinkOverridesRepository links = await LinkOverridesRepository.create(
    db: firebaseReady ? FirebaseFirestore.instance : null,
  );
  game.applyLinkOverrides(links.loadCached());
  if (links.isStale) {
    unawaited(links.refresh().then((Map<String, LinkOverride>? fresh) {
      if (fresh != null) game.applyLinkOverrides(fresh);
    }));
  }

  // MixRun is side-loaded rather than installed from a store, so nothing tells
  // a player a new APK exists. The home screen asks this repository once per
  // launch and prompts when a newer build has been published.
  final AppUpdateRepository updates = await AppUpdateRepository.create(
    db: firebaseReady ? FirebaseFirestore.instance : null,
  );

  // Drive the looping background music and the sound-effects gate off the
  // player's audio toggles. The calls are idempotent, so reacting to every
  // controller change is harmless.
  final AudioService audio = AudioService();
  void syncAudio() {
    audio.setMusicEnabled(game.musicOn);
    audio.setSoundEnabled(game.soundOn);
  }
  game.addListener(syncAudio);
  syncAudio();

  final AccountController account = AccountController(
    game: game,
    available: firebaseReady,
    auth: firebaseReady ? AuthService(FirebaseAuth.instance) : null,
    cloud: firebaseReady
        ? CloudProgressRepository(FirebaseFirestore.instance)
        : null,
  );

  runApp(MixRunApp(
    controller: game,
    account: account,
    rewardedAds: rewardedAds,
    audio: audio,
    updates: updates,
  ));
}
