import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mixrun/data/game_data.dart';
import 'package:mixrun/data/link_overrides_repository.dart';
import 'package:mixrun/data/progress_repository.dart';
import 'package:mixrun/domain/game_controller.dart';

Future<GameController> _controller() async {
  final ProgressRepository repository = await ProgressRepository.create();
  return GameController(repository);
}

void main() {
  const String cacheKey = 'mixrun.linkOverrides';

  group('link resolution falls back to the catalog', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('an element with no override keeps its baked-in links', () async {
      final GameController game = await _controller();
      expect(game.articleUrlFor('earth'), GameData.element('earth').url);
      expect(game.videoUrlFor('earth'), GameData.element('earth').videoUrl);
    });

    test('an override replaces only the field it sets', () async {
      final GameController game = await _controller();
      game.applyLinkOverrides(<String, LinkOverride>{
        'earth': const LinkOverride(videoUrl: 'https://youtu.be/NEW'),
      });

      // The video is corrected; the article is untouched.
      expect(game.videoUrlFor('earth'), 'https://youtu.be/NEW');
      expect(game.articleUrlFor('earth'), GameData.element('earth').url);

      // Other elements are unaffected.
      expect(game.articleUrlFor('water'), GameData.element('water').url);
    });

    test('an override for an unknown id never breaks a real one', () async {
      final GameController game = await _controller();
      game.applyLinkOverrides(<String, LinkOverride>{
        'not-an-element': const LinkOverride(url: 'https://example.com'),
      });
      expect(game.articleUrlFor('earth'), GameData.element('earth').url);
    });
  });

  group('cached overrides', () {
    test('a valid cache is loaded', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        cacheKey: jsonEncode(<String, dynamic>{
          'tajmahal': <String, String>{'v': 'https://youtu.be/ABC'},
          'sitar': <String, String>{'u': 'https://en.wikipedia.org/wiki/Sitar'},
        }),
      });
      final LinkOverridesRepository repo =
          await LinkOverridesRepository.create();
      final Map<String, LinkOverride> loaded = repo.loadCached();

      expect(loaded.length, 2);
      expect(loaded['tajmahal']!.videoUrl, 'https://youtu.be/ABC');
      expect(loaded['tajmahal']!.url, isNull);
      expect(loaded['sitar']!.url, 'https://en.wikipedia.org/wiki/Sitar');
    });

    test('a corrupt cache resolves to no overrides, not a crash', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        cacheKey: 'not json at all',
      });
      final LinkOverridesRepository repo =
          await LinkOverridesRepository.create();
      expect(repo.loadCached(), isEmpty);
    });

    test('junk entries are dropped, good ones kept', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        cacheKey: jsonEncode(<String, dynamic>{
          'good': <String, String>{'v': 'https://youtu.be/OK'},
          'wrongShape': 'a bare string',
          'emptyValues': <String, String>{'u': '   ', 'v': ''},
          'noFields': <String, String>{},
        }),
      });
      final LinkOverridesRepository repo =
          await LinkOverridesRepository.create();
      final Map<String, LinkOverride> loaded = repo.loadCached();

      expect(loaded.keys, <String>['good']);
      expect(loaded['good']!.videoUrl, 'https://youtu.be/OK');
    });

    test('with no Firebase, refresh is a no-op and keeps the cache', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        cacheKey: jsonEncode(<String, dynamic>{
          'tajmahal': <String, String>{'v': 'https://youtu.be/ABC'},
        }),
      });
      final LinkOverridesRepository repo =
          await LinkOverridesRepository.create();

      expect(await repo.refresh(), isNull);
      expect(repo.loadCached().length, 1);
    });

    test('an empty cache is stale, so the first launch fetches', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final LinkOverridesRepository repo =
          await LinkOverridesRepository.create();
      expect(repo.isStale, isTrue);
      expect(repo.loadCached(), isEmpty);
    });
  });
}
