# MixRun

**A gentle crafting game that turns curiosity into discovery, and quietly teaches kids about the world around them.**

![MixRun cover](docs/cover_image.png)

---

## What is MixRun?

MixRun starts you with just four things: **Earth, Water, Fire, and Air**. Drag two together and watch something new appear. Mix those results again, and again, and a whole world unfolds under your fingertips: **hundreds of items to discover**, from clouds and rivers to festivals, monuments, art forms, and the heroes who shaped a nation.

There's no timer, no losing, and no pressure. Just the quiet joy of *"what happens if I combine these two?"*, the same spark that makes kids take things apart to see how they work.

### Why children (and parents) love it

- **Discovery, not instructions.** Every new item is a little reward the player earns by experimenting. It builds patience, pattern-recognition, and creative thinking.
- **It sneaks in real learning.** MixRun's world is built around **Indian heritage**: its states, history, culture, arts, and heroes. Discover an item and you can tap **"Read More"** for a kid-friendly explanation, or **"Watch a Video"** to see it come alive. Curiosity leads straight to knowledge.
- **Safe by design.** Videos are curated and filtered for safe viewing. There's no chat, no strangers, and the game plays perfectly **offline**, with no account required to start.
- **A journey to travel.** Items are grouped into themed stages: a **Base** world of nature and science, then stops through **States, History, Culture, Arts, and Heroes**, unlocked step by step as a child explores.
- **Made for everyone.** MixRun is being built for **16 languages** so children can play and learn in the words they know best. (More on how you can help below!)

Whether it's a five-minute wind-down or a rainy afternoon of exploring, MixRun is a calm, screen-time-you-can-feel-good-about kind of game.

---

## A huge shoutout to Little Alchemy 2

MixRun stands entirely on the shoulders of **[Little Alchemy 2](https://littlealchemy2.com/)**, the wonderful game that invented and perfected this "combine two things to make a third" magic. If you love MixRun's core idea, it's because Little Alchemy 2 got it so right first.

MixRun is a heartfelt homage: the same joyful mechanic, reimagined as a journey through Indian heritage and built as a learning tool for children. All the credit for the original spark goes to the Little Alchemy 2 team. **Thank you.**

---

## For developers & contributors

**MixRun is open to your help. Anyone is welcome to raise a Pull Request.**

This is a Flutter project, and the game world is intentionally easy to tweak. You don't have to be a game designer to make it better. Here's how you can pitch in:

- **Suggest or fix items.** Think an item's description could be clearer, a combination doesn't make sense, or there's a great heritage item we're missing? Open a PR or an issue with your idea. The catalog is designed to be edited.
- **Fix broken links.** Every item carries a "Read More" article link and a "Watch a Video" link. Links rot over time, so if you spot a dead or wrong one, please send a fix. (Small corrections can even be pushed without a full release; see *Fixing a broken "learn more" link* below.)
- **Help translate the game.** This is one of the biggest ways to help. MixRun is wired for **16 locales** but is currently **English-only**. If you speak another language, you can help translate both the interface and the item content so more children can play in their own language. Contributions here are hugely appreciated.
- **Report bugs & propose features.** Found something broken or have an idea? Open an issue. Clear reproduction steps make fixes fast.

**How to contribute:** fork the repo, make your change on a branch, and open a PR describing *what* you changed and *why*. No change is too small; fixing a typo in an item description genuinely helps a kid somewhere learn something correctly.

> A note on the data files: the game catalog is public and lives right in the repo (see *Game data* below). To suggest an item or content change, edit `lib/data/game_data.dart` directly and open a PR so your intent is clear.

---

## Game data

The full game catalog is **public and committed to the repo**, so you can read
and edit it directly. There is nothing to copy before building.

| File                          | What it holds                                                                 |
| ----------------------------- | ----------------------------------------------------------------------------- |
| `lib/data/game_data.dart`     | Every item: name, description, category, article/video links, and the recipes that combine them |
| `lib/data/game_levels.dart`   | How items are grouped into the Journey's themed stages                        |
| `lib/data/element_icons.dart` | The icon mapping for each item                                                |

Each file has an `*.example.dart` companion kept alongside it as a small,
self-contained reference version. You do not need it to build; the real files
above are what the app uses.

To change an item, edit its entry in `lib/data/game_data.dart` and open a PR.

## Secrets and local config

Nothing in this repo contains a live credential. The values that identify the
real Firebase and AdMob accounts are supplied locally and are **gitignored**, so
a clone builds and runs without them.

| Real file / value (gitignored)       | How to supply it                              |
| ------------------------------------ | --------------------------------------------- |
| `android/app/google-services.json`   | copy `google-services.example.json`, fill in your Firebase project |
| `android/local.properties`           | `admob.appId=ca-app-pub-XXX~YYY`              |
| Rewarded ad unit                     | `--dart-define=ADMOB_REWARDED_AD_UNIT_ID=...` |
| Test device ids                      | `--dart-define=ADMOB_TEST_DEVICE_IDS=HASH1,HASH2` |
| `android/key.properties` + the `.jks` | release signing, see below                   |

**Firebase.** Without `google-services.json` the app runs fully offline with
account features disabled,  `main.dart` catches the init failure, and
`build.gradle.kts` only applies the Google Services plugin when the file exists.
To enable accounts, copy the template and replace every `REPLACE_ME` value with
your own project's:

```sh
cp android/app/google-services.example.json android/app/google-services.json
```

**AdMob.** The app id is injected into `AndroidManifest.xml` as a manifest
placeholder by `android/app/build.gradle.kts`, read from `admob.appId` in
`android/local.properties` (or `-Padmob.appId=`, or an `ADMOB_APP_ID` env var
for CI). With none set it falls back to Google's public test app id, so a fresh
clone builds and serves test ads without an AdMob account.

The rewarded ad unit works the same way: release builds use
`ADMOB_REWARDED_AD_UNIT_ID` when defined, and otherwise fall back to Google's
sample unit rather than requesting a unit that doesn't exist.

```sh
flutter build apk --release \
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID=ca-app-pub-XXX/YYY
```

**Test devices.** Registering your handset makes AdMob serve *test* creatives
you can safely tap,  tapping a live ad on your own app is invalid traffic and
can get the account suspended. Device ids are personal to a handset, so they are
passed at build time and never committed:

```sh
flutter run --dart-define=ADMOB_TEST_DEVICE_IDS=33BE2250B43518CCDA7DE426D04EE231
```

**Release signing.** Release builds are signed with the keystore described by
`android/key.properties` (gitignored):

```properties
storePassword=...
keyPassword=...
keyAlias=mixrun
storeFile=C:/Users/you/keystores/mixrun-release.jks
```

Without that file the build falls back to the debug key and logs a warning.
Such an APK still runs, so a fresh clone builds — but **never distribute one**:
the debug key is generated per machine, so the next machine produces an APK
Android refuses to install over it.

That last point is why this keystore matters more here than in a store-published
app. Android only installs an update signed with the *same* key as the installed
build, and MixRun updates itself in place. **Back up the `.jks` and its
password.** Lose either and no installed copy can ever be updated again — every
player would have to uninstall (losing local progress) and start over. A leaked
keystore is the mirror risk: it lets anyone ship an update impersonating this app.

Generating one, if you're setting up from scratch:

```sh
keytool -genkeypair -v -keystore ~/keystores/mixrun-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias mixrun
```

Keep it outside the repo. If the app uses Google Sign-In, add the new
certificate's SHA-1 to the Firebase console (Project settings → Your apps) and
re-download `google-services.json`, or sign-in fails in release builds.

## Fixing a broken "learn more" link

Every element ships with an article URL and (once curated) a video URL baked
into `lib/data/game_data.dart`. Links rot, so those can be corrected
server-side without releasing an update.

Edit the Firestore document **`config/links`**. It holds only the links that
have broken, not a copy of the catalog:

```json
{
  "items": {
    "tajmahal": { "v": "https://www.youtube.com/watch?v=NEW_ID" },
    "sitar":    { "u": "https://en.wikipedia.org/wiki/Sitar" }
  }
}
```

- `u` replaces the article URL, `v` replaces the video URL. Set only the one
  that broke; the other keeps its baked-in value.
- Keys are element ids from `game_data.dart`. An id that doesn't exist is
  ignored.
- Deploy `firestore.rules` (`firebase deploy --only firestore:rules`) so the
  document is world-readable and client-writable by nobody. Most players never
  sign in, and a fix is only useful if it reaches them too.

Clients apply the cached copy before the first frame and refresh in the
background at most every 12 hours, so corrections reach players on their next
launch or two. Every failure path (no Firebase, offline, permission denied, a
malformed document) falls back to the link baked into the app.

## Releasing a new version

MixRun is side-loaded as an APK rather than installed from a store, so nothing
tells a player a new build exists. One Firestore document does: on launch the
home screen compares the running build against **`config/app_version`** and
prompts to download when it is behind (see
`lib/data/app_update_repository.dart`).

To ship a release:

1. **Bump the version** in `pubspec.yaml` — both parts, e.g.
   `version: 1.1.0+2`. The number after `+` is the build number
   (Android's `versionCode`) and is the *only* thing compared; version *names*
   are never compared, because `1.10.0` sorts before `1.9.0` as a string.
2. **Build and upload the APK.**

   ```sh
   flutter build apk --release
   ```

   Upload `build/app/outputs/flutter-apk/app-release.apk` somewhere with a
   stable public URL — Firebase Storage, GitHub Releases, any static host.
   Use a versioned filename so an old link never serves the new build.
3. **Publish the release.** `tools/publish_release.py` reads the version from
   `pubspec.yaml`, refuses a `downloadUrl` it can't fetch, and writes the
   document with the Admin SDK (needs `pip install firebase-admin` and a service
   account key in `GOOGLE_APPLICATION_CREDENTIALS`):

   ```sh
   python tools/publish_release.py --url https://.../mixrun-1.1.0.apk \
       --notes "New Heroes level\nFaster canvas"
   ```

   Or edit `config/app_version` in the Firebase console by hand — one field
   named `android` of type *map*, holding:

   ```json
   {
     "android": {
       "versionCode": 2,
       "versionName": "1.1.0",
       "minVersionCode": 1,
       "downloadUrl": "https://example.com/mixrun-1.1.0.apk",
       "notes": "New Heroes level and a faster canvas."
     }
   }
   ```

   - `versionCode` — build number of the new APK. Players below it are offered
     the update.
   - `minVersionCode` — oldest build still supported. Players below it are
     *forced*: the prompt cannot be dismissed. Leave it alone for an ordinary
     release; raise it only when an old build is genuinely broken (say, a
     Firestore schema it can't read).
   - `downloadUrl` — opened in the browser, which hands the file to Android's
     download manager. That needs no extra permission from the app; the player
     taps the finished download to install.
   - `notes` — optional "what's new" blurb shown in the prompt.
4. **Deploy the rules** once, if you haven't:
   `firebase deploy --only firestore:rules`. The document is world-readable
   (most players never sign in) and writable by no client — a client able to
   change `downloadUrl` could point players at an APK we didn't build.

Players see the prompt on their next launch. "Later" silences an optional
update for 3 days, or until a newer `versionCode` is published. The check runs
at most once every 6 hours and the last result is cached, so a *required*
update still blocks even if the device is offline afterwards. Every failure
path (no Firebase, offline, a malformed document) simply shows no prompt.

To test the flow before releasing, publish a `versionCode` above the one you're
running and launch the app.

## Building & running

MixRun is a standard Flutter app. After copying the templates above:

```sh
flutter pub get
flutter run
```

New to Flutter? These will get you set up:

- [Install Flutter](https://docs.flutter.dev/get-started/install)
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter documentation](https://docs.flutter.dev/)

---

*MixRun is a fan-made, educational homage to Little Alchemy 2. Come build a little world, and help us make it better for kids everywhere.*
