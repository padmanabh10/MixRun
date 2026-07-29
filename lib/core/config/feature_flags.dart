/// Compile-time feature toggles for MixRun.
///
/// These let us ship complete-but-dormant features that stay in the codebase
/// without being reachable by players until we flip the flag.
abstract final class FeatureFlags {
  /// Whether the hints feature (active hints + rewarded-ad unlocks) is live.
  ///
  /// Disabled for now: rewarded ads need a Google Play developer account and
  /// AdMob monetization we don't have yet. The full hints UI and engine remain
  /// intact behind this flag (see [HintsScreen]); while it's off, the Hints
  /// screen shows a collaboration invite instead. Flip to `true` once an
  /// AdMob-enabled release is in place.
  static const bool hintsEnabled = false;

  /// Whether the in-app language selector in Settings is live.
  ///
  /// Disabled for now: game content is English-only (the [ContentL10n] maps are
  /// empty), so switching languages would only translate UI chrome. The full
  /// selector stays intact behind this flag; flip to `true` once translations
  /// ship in a later version.
  static const bool languageSelectionEnabled = false;
}
