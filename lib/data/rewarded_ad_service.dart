import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Loads and presents AdMob rewarded video ads.
///
/// The hints feature uses this to gate a fresh hint behind a fully-watched ad:
/// callers pass an [onUserEarnedReward] callback to [showAd] that fires only
/// when the player finishes the video and earns the reward. A single rewarded
/// ad is single-use, so the service preloads the next one as soon as the
/// current one is dismissed.
class RewardedAdService extends ChangeNotifier {
  RewardedAdService({String? adUnitId})
      : _adUnitId = adUnitId ??
            (kReleaseMode && _prodAdUnitId.isNotEmpty
                ? _prodAdUnitId
                : _sampleAdUnitId);

  /// Production rewarded ad unit (Android), supplied at build time so the
  /// account's real unit id stays out of source control:
  ///
  /// ```sh
  /// flutter build apk --dart-define=ADMOB_REWARDED_AD_UNIT_ID=ca-app-pub-XXX/YYY
  /// ```
  ///
  /// Empty by default, in which case even release builds fall back to the
  /// sample unit below rather than requesting a unit that does not exist. A
  /// brand-new unit can return "no fill" for the first hours after creation
  /// until AdMob activates it,  this is expected.
  static const String _prodAdUnitId =
      String.fromEnvironment('ADMOB_REWARDED_AD_UNIT_ID');

  /// Google's official sample rewarded unit. It always fills with a test ad, so
  /// debug/profile builds use it to verify the flow regardless of whether the
  /// production unit has been activated yet.
  static const String _sampleAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  final String _adUnitId;

  RewardedAd? _ad;
  bool _isLoading = false;
  bool _disposed = false;

  /// True while an ad is in flight from AdMob.
  bool get isLoading => _isLoading;

  /// True when an ad is loaded and ready to be shown immediately.
  bool get isReady => _ad != null;

  /// Requests a rewarded ad if one isn't already loaded or loading.
  void load() {
    if (_disposed || _isLoading || _ad != null) return;
    _isLoading = true;
    _safeNotify();
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          if (_disposed) {
            ad.dispose();
            return;
          }
          _ad = ad;
          _isLoading = false;
          _safeNotify();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _ad = null;
          _isLoading = false;
          _safeNotify();
        },
      ),
    );
  }

  /// Shows the loaded rewarded ad, invoking [onUserEarnedReward] only once the
  /// player finishes watching. Returns false (without showing anything) when no
  /// ad is ready yet, in which case a fresh load is kicked off for next time.
  Future<bool> showAd({required VoidCallback onUserEarnedReward}) async {
    final RewardedAd? ad = _ad;
    if (ad == null) {
      load();
      return false;
    }

    // A rewarded ad can only be shown once; release our reference up front and
    // preload a replacement when this one goes away.
    _ad = null;
    _safeNotify();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        load();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        load();
      },
    );

    await ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) =>
          onUserEarnedReward(),
    );
    return true;
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _ad?.dispose();
    _ad = null;
    super.dispose();
  }
}
