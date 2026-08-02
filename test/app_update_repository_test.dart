import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mixrun/data/app_update_repository.dart';

/// A release published in Firestore, as it lands in the local cache.
///
/// Seeding the cache exercises the same comparison the live path uses: with no
/// Firestore instance the repository falls back to the cached release, so these
/// tests cover the decision logic without a network.
String _cached({
  int versionCode = 5,
  String versionName = '1.2.0',
  int minVersionCode = 0,
}) =>
    jsonEncode(<String, Object>{
      'versionCode': versionCode,
      'versionName': versionName,
      'minVersionCode': minVersionCode,
      'downloadUrl': 'https://example.test/mixrun-$versionName.apk',
    });

Future<AppUpdateRepository> _repository({
  required int currentVersionCode,
  Map<String, Object> prefs = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  return AppUpdateRepository(
    prefs: await SharedPreferences.getInstance(),
    currentVersionCode: currentVersionCode,
  );
}

void main() {
  test('says nothing when no release has ever been fetched', () async {
    final AppUpdateRepository updates =
        await _repository(currentVersionCode: 3);

    expect((await updates.check()).urgency, UpdateUrgency.none);
  });

  test('says nothing when the running build is the published one', () async {
    final AppUpdateRepository updates = await _repository(
      currentVersionCode: 5,
      prefs: <String, Object>{'mixrun.latestRelease': _cached(versionCode: 5)},
    );

    expect((await updates.check()).urgency, UpdateUrgency.none);
  });

  test('offers an optional update when a newer build is published', () async {
    final AppUpdateRepository updates = await _repository(
      currentVersionCode: 4,
      prefs: <String, Object>{'mixrun.latestRelease': _cached(versionCode: 5)},
    );

    final UpdateStatus status = await updates.check();
    expect(status.urgency, UpdateUrgency.optional);
    expect(status.isRequired, isFalse);
    expect(status.release?.versionName, '1.2.0');
  });

  test('requires an update below the minimum supported build', () async {
    final AppUpdateRepository updates = await _repository(
      currentVersionCode: 2,
      prefs: <String, Object>{
        'mixrun.latestRelease': _cached(versionCode: 5, minVersionCode: 3),
      },
    );

    expect((await updates.check()).isRequired, isTrue);
  });

  test('snoozing silences that build but not a later one', () async {
    final AppUpdateRepository updates = await _repository(
      currentVersionCode: 4,
      prefs: <String, Object>{'mixrun.latestRelease': _cached(versionCode: 5)},
    );

    final UpdateStatus status = await updates.check();
    await updates.snooze(status.release!);
    expect((await updates.check()).urgency, UpdateUrgency.none);

    // Build 6 ships: the snooze was for 5, so the player hears about it.
    SharedPreferences.setMockInitialValues(<String, Object>{
      'mixrun.latestRelease': _cached(versionCode: 6, versionName: '1.3.0'),
      'mixrun.updateSnoozedCode': 5,
      'mixrun.updateSnoozedAt': DateTime.now().millisecondsSinceEpoch,
    });
    final AppUpdateRepository next = AppUpdateRepository(
      prefs: await SharedPreferences.getInstance(),
      currentVersionCode: 4,
    );
    expect((await next.check()).urgency, UpdateUrgency.optional);
  });

  test('a snooze never suppresses a required update', () async {
    final AppUpdateRepository updates = await _repository(
      currentVersionCode: 2,
      prefs: <String, Object>{
        'mixrun.latestRelease': _cached(versionCode: 5, minVersionCode: 3),
        'mixrun.updateSnoozedCode': 5,
        'mixrun.updateSnoozedAt': DateTime.now().millisecondsSinceEpoch,
      },
    );

    expect((await updates.check()).isRequired, isTrue);
  });

  test('ignores a release document missing its download URL', () async {
    final AppUpdateRepository updates = await _repository(
      currentVersionCode: 4,
      prefs: <String, Object>{
        'mixrun.latestRelease': jsonEncode(<String, Object>{'versionCode': 9}),
      },
    );

    expect((await updates.check()).urgency, UpdateUrgency.none);
  });

  test('ignores a corrupt cache rather than throwing', () async {
    final AppUpdateRepository updates = await _repository(
      currentVersionCode: 4,
      prefs: <String, Object>{'mixrun.latestRelease': 'not json'},
    );

    expect((await updates.check()).urgency, UpdateUrgency.none);
  });
}
