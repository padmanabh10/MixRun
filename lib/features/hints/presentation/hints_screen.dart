import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../core/utils/external_links.dart';
import '../../../data/audio_service.dart';
import '../../../data/rewarded_ad_service.dart';
import '../../../domain/game_controller.dart';
import '../../shared/widgets/gold_button.dart';
import '../../shared/widgets/hint_showcase.dart';
import '../../shared/widgets/light_back_button.dart';
import '../../shared/widgets/parchment_scaffold.dart';

/// Offers "active hints": random, still-makeable elements to aim for. Each hint
/// reveals its target's name but not its recipe and stays active until the
/// player combines their way to discovering it.
///
/// A fresh hint costs a fully-watched rewarded video (see [_earnHint]). Players
/// may unlock up to [GameController.dailyHintLimit] per day and hold at most
/// [GameController.maxActiveHints] at once.
class HintsScreen extends StatefulWidget {
  const HintsScreen({super.key});

  @override
  State<HintsScreen> createState() => _HintsScreenState();
}

class _HintsScreenState extends State<HintsScreen> {
  @override
  void initState() {
    super.initState();
    // While hints are disabled there's no ad to play, so don't bother loading
    // one. Make sure an ad is ready (or loading) the moment the screen opens,
    // even if the initial preload from startup failed.
    if (FeatureFlags.hintsEnabled) {
      context.read<RewardedAdService>().load();
    }
  }

  /// Plays a rewarded ad and, only on completion, unlocks a new hint. Refuses
  /// up front (with a reason) when the player is out of daily hints, at the
  /// active-hint cap, or has nothing left to be hinted at.
  Future<void> _earnHint() async {
    final RewardedAdService ads = context.read<RewardedAdService>();
    final GameController controller = context.read<GameController>();
    final AudioService audio = context.read<AudioService>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final AppLocalizations strings = AppLocalizations.of(context);

    if (!controller.canRequestHint) {
      audio.playEffect(Sfx.hintBlocked);
      messenger.showSnackBar(
        SnackBar(content: Text(_blockedReason(controller, strings))),
      );
      return;
    }

    String? unlocked;
    final bool shown = await ads.showAd(
      onUserEarnedReward: () {
        audio.playEffect(Sfx.reward);
        controller.recordAdWatched();
        unlocked = controller.requestHint();
        if (unlocked != null) audio.playEffect(Sfx.hint);
      },
    );
    if (!shown) {
      messenger.showSnackBar(SnackBar(content: Text(strings.adNotReady)));
      return;
    }
    // Celebrate the freshly unlocked hint with a full-screen reveal.
    final String? earned = unlocked;
    if (earned != null && mounted) {
      await showHintShowcase(context, earned);
    }
  }

  /// Explains why a new hint can't be unlocked right now.
  String _blockedReason(GameController controller, AppLocalizations strings) {
    if (controller.hintsRemainingToday <= 0) {
      return strings.dailyHintLimitReached;
    }
    if (controller.activeHintCount >= GameController.maxActiveHints) {
      return strings.maxHintsReached;
    }
    return strings.noHint;
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final RewardedAdService ads = context.watch<RewardedAdService>();
    final AppLocalizations strings = AppLocalizations.of(context);
    // Show a spinner while an ad is being fetched and none is ready to play yet.
    final bool adLoading = ads.isLoading && !ads.isReady;

    return ParchmentScaffold(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: <Widget>[
                LightBackButton(
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go(AppRoutes.game),
                ),
                const SizedBox(width: 10),
                Text(
                  strings.hint,
                  style: AppText.display(
                    size: 22,
                    weight: FontWeight.w800,
                    color: AppColors.cocoa,
                  ),
                ),
              ],
            ),
          ),
          // Hints are gated behind a feature flag for now (no AdMob account
          // yet). While off, show a collaboration invite instead of the live
          // hints UI. The full hints experience below stays untouched and
          // returns the moment the flag is flipped.
          Expanded(
            child: FeatureFlags.hintsEnabled
                ? _Body(
                    controller: controller,
                    strings: strings,
                    adLoading: adLoading,
                    onEarnHint: _earnHint,
                  )
                : const _CollaborationInvite(),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.controller,
    required this.strings,
    required this.adLoading,
    required this.onEarnHint,
  });

  final GameController controller;
  final AppLocalizations strings;

  /// True while a rewarded ad is being fetched and none is ready to play yet.
  final bool adLoading;

  /// Plays a rewarded ad and, only on completion, unlocks a new hint.
  final VoidCallback onEarnHint;

  @override
  Widget build(BuildContext context) {
    final List<String> hints = controller.activeHints;
    final bool atDailyLimit = controller.hintsRemainingToday <= 0;
    final bool atMax = controller.activeHintCount >= GameController.maxActiveHints;

    return Column(
      children: <Widget>[
        _SummaryBar(controller: controller, strings: strings),
        Expanded(
          child: hints.isEmpty
              ? _EmptyState(strings: strings)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                  itemCount: hints.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HintTile(
                      name: controller.elementName(hints[index]),
                      strings: strings,
                      onTap: () => context.go(AppRoutes.game),
                    ),
                  ),
                ),
        ),
        _Footer(
          strings: strings,
          adLoading: adLoading,
          atDailyLimit: atDailyLimit,
          atMax: atMax,
          onEarnHint: onEarnHint,
        ),
      ],
    );
  }
}

/// A compact strip showing how many hints are active and how many remain today.
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.controller, required this.strings});

  final GameController controller;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Row(
        children: <Widget>[
          Icon(Icons.lightbulb_rounded,
              size: 18, color: AppColors.gold.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            '${strings.activeHintsTitle}  ${controller.activeHintCount}',
            style: AppText.display(
              size: 14,
              weight: FontWeight.w700,
              color: AppColors.cocoa,
            ),
          ),
          const Spacer(),
          Text(
            strings.hintsLeftToday(controller.hintsRemainingToday),
            style: AppText.body(size: 12, color: AppColors.mutedBrown),
          ),
        ],
      ),
    );
  }
}

/// Shown when there are no active hints yet.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.lightbulb_outline_rounded,
                size: 56, color: AppColors.gold.withValues(alpha: 0.85)),
            const SizedBox(height: 16),
            Text(
              strings.figureOutRecipe,
              textAlign: TextAlign.center,
              style: AppText.body(size: 14, color: AppColors.mutedBrown),
            ),
          ],
        ),
      ),
    );
  }
}

/// One active-hint card: a mystery tile plus the target element's name. The
/// artwork stays hidden so discovering it on the canvas is still a reveal.
class _HintTile extends StatelessWidget {
  const _HintTile({
    required this.name,
    required this.strings,
    required this.onTap,
  });

  final String name;
  final AppLocalizations strings;

  /// Jumps to the canvas so the player can start combining toward this hint.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE2C4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '?',
                    style: AppText.display(
                      size: 26,
                      weight: FontWeight.w800,
                      color: AppColors.lockedBrown,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: AppText.display(
                          size: 18,
                          weight: FontWeight.w800,
                          color: AppColors.cocoa,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings.figureOutRecipe,
                        style:
                            AppText.body(size: 12, color: AppColors.mutedBrown),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.spiceBrown),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The bottom action area: either the "watch a video for a hint" button or a
/// message explaining why no new hint can be unlocked right now.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.strings,
    required this.adLoading,
    required this.atDailyLimit,
    required this.atMax,
    required this.onEarnHint,
  });

  final AppLocalizations strings;
  final bool adLoading;
  final bool atDailyLimit;
  final bool atMax;
  final VoidCallback onEarnHint;

  @override
  Widget build(BuildContext context) {
    final String? blockedMessage = atDailyLimit
        ? strings.dailyHintLimitReached
        : (atMax ? strings.maxHintsReached : null);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 6, 28, 28),
      child: blockedMessage != null
          ? Text(
              blockedMessage,
              textAlign: TextAlign.center,
              style: AppText.body(size: 13, color: AppColors.mutedBrown),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GoldButton(
                  label: adLoading ? strings.loadingAd : strings.getHint,
                  leading: adLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onGold,
                          ),
                        )
                      : const Icon(Icons.ondemand_video_rounded,
                          size: 20, color: AppColors.onGold),
                  // Swallow taps while loading so players can't queue requests.
                  onPressed: adLoading ? () {} : onEarnHint,
                  fontSize: 17,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
                  borderRadius: 16,
                ),
                const SizedBox(height: 10),
                Text(
                  strings.watchAdForHint,
                  textAlign: TextAlign.center,
                  style: AppText.body(size: 12, color: AppColors.mutedBrown),
                ),
              ],
            ),
    );
  }
}

/// Stand-in shown while the hints feature is disabled (see [FeatureFlags]).
///
/// Rather than a hint or a "watch a video" button, it tells players hints
/// aren't available yet and invites anyone with a Google Play developer
/// account to collaborate on releasing MixRun with monetization.
class _CollaborationInvite extends StatelessWidget {
  const _CollaborationInvite();

  static const String _contactEmail = 'officialpadmanabh@gmail.com';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.lightbulb_outline_rounded,
              size: 56,
              color: AppColors.gold.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 18),
            Text(
              "Hints aren't available at the moment",
              textAlign: TextAlign.center,
              style: AppText.display(
                size: 20,
                weight: FontWeight.w800,
                color: AppColors.cocoa,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Hints are powered by rewarded ads, which need a Google Play '
              'developer account to go live. If you have one, let’s collaborate '
              'to release MixRun on the Play Store and turn on monetization.',
              textAlign: TextAlign.center,
              style: AppText.body(size: 14, color: AppColors.mutedBrown),
            ),
            const SizedBox(height: 24),
            GoldButton(
              label: 'Get in touch',
              leading: const Icon(
                Icons.mail_outline_rounded,
                size: 20,
                color: AppColors.onGold,
              ),
              onPressed: () => openEmail(
                _contactEmail,
                subject: 'Collaborating to release MixRun',
              ),
              fontSize: 17,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              borderRadius: 16,
            ),
            const SizedBox(height: 12),
            Text(
              _contactEmail,
              textAlign: TextAlign.center,
              style: AppText.body(size: 13, color: AppColors.spiceBrown),
            ),
          ],
        ),
      ),
    );
  }
}
