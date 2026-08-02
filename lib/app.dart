import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/app_update_repository.dart';
import 'data/audio_service.dart';
import 'data/rewarded_ad_service.dart';
import 'domain/account_controller.dart';
import 'domain/game_controller.dart';
import 'l10n/gen/app_localizations.dart';

/// Root widget. Provides the [GameController], [AccountController],
/// [RewardedAdService] and [AppUpdateRepository] to the tree and wires up
/// theming, localization and declarative routing.
class MixRunApp extends StatelessWidget {
  const MixRunApp({
    super.key,
    required this.controller,
    required this.account,
    required this.rewardedAds,
    required this.audio,
    required this.updates,
  });

  final GameController controller;
  final AccountController account;
  final RewardedAdService rewardedAds;
  final AudioService audio;
  final AppUpdateRepository updates;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameController>.value(value: controller),
        ChangeNotifierProvider<AccountController>.value(value: account),
        ChangeNotifierProvider<RewardedAdService>.value(value: rewardedAds),
        Provider<AudioService>.value(value: audio),
        Provider<AppUpdateRepository>.value(value: updates),
      ],
      // Rebuild MaterialApp when the player switches language.
      child: Consumer<GameController>(
        builder: (context, controller, _) => MaterialApp.router(
          title: 'MixRun',
          theme: AppTheme.light(),
          routerConfig: AppRouter.router,
          locale: controller.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
