import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../data/models/app_language.dart';
import '../../../domain/account_controller.dart';
import '../../../domain/game_controller.dart';
import '../../shared/widgets/light_back_button.dart';
import '../../shared/widgets/parchment_scaffold.dart';
import '../../shared/widgets/progress_bar.dart';
import 'widgets/labeled_toggle.dart';
import 'widgets/settings_section.dart';

/// Audio, progress management and app information.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _resetArmed = false;

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final AccountController account = context.watch<AccountController>();
    final AppLocalizations strings = AppLocalizations.of(context);

    return ParchmentScaffold(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: <Widget>[
                  const LightBackButton(),
                  const SizedBox(width: 10),
                  Text(
                    strings.settings,
                    style: AppText.display(
                      size: 22,
                      weight: FontWeight.w800,
                      color: AppColors.cocoa,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _accountSection(context, account, strings),
                  const SizedBox(height: 18),
                  // Language selector is deferred to a later version (content is
                  // English-only for now),  see [FeatureFlags].
                  if (FeatureFlags.languageSelectionEnabled) ...<Widget>[
                    _languageSection(controller, strings),
                    const SizedBox(height: 18),
                  ],
                  _audioSection(controller, strings),
                  const SizedBox(height: 18),
                  _progressSection(controller, strings),
                  const SizedBox(height: 18),
                  _helpSection(context, strings),
                  const SizedBox(height: 18),
                  _aboutCard(strings),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountSection(
    BuildContext context,
    AccountController account,
    AppLocalizations strings,
  ) {
    return SettingsSection(
      title: strings.account,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cocoa.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _accountBody(context, account, strings),
      ),
    );
  }

  Widget _accountBody(
    BuildContext context,
    AccountController account,
    AppLocalizations strings,
  ) {
    if (!account.available) {
      return Text(
        strings.accountUnavailable,
        style: AppText.body(size: 13, color: AppColors.mutedBrown),
      );
    }
    if (account.isSignedIn) {
      return Row(
        children: <Widget>[
          const Icon(Icons.account_circle_rounded,
              size: 36, color: AppColors.spiceBrown),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              account.accountLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.display(
                size: 15,
                weight: FontWeight.w700,
                color: AppColors.cocoa,
              ),
            ),
          ),
          TextButton(
            onPressed: account.busy ? null : account.signOut,
            child: Text(
              strings.signOut,
              style: AppText.display(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.brick,
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          strings.signInBlurb,
          style: AppText.body(size: 13, color: AppColors.mutedBrown),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.push(AppRoutes.login),
          child: Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              strings.signIn,
              style: AppText.display(
                size: 15,
                weight: FontWeight.w700,
                color: AppColors.spiceBrown,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _languageSection(GameController controller, AppLocalizations strings) {
    final AppLanguage current =
        AppLanguage.fromCode(controller.locale.languageCode);
    return SettingsSection(
      title: strings.language,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cocoa.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: PopupMenuButton<String>(
          initialValue: current.code,
          onSelected: (String code) => controller.setLocale(Locale(code)),
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            for (final AppLanguage lang in AppLanguage.all)
              PopupMenuItem<String>(
                value: lang.code,
                child: _LanguageRow(language: lang),
              ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Expanded(child: _LanguageRow(language: current)),
                const Icon(Icons.expand_more_rounded,
                    color: AppColors.spiceBrown),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _audioSection(GameController controller, AppLocalizations strings) {
    return SettingsSection(
      title: strings.audio,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cocoa.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: <Widget>[
            LabeledToggle(
              label: strings.sound,
              value: controller.soundOn,
              onChanged: (_) => controller.toggleSound(),
              showDivider: true,
            ),
            LabeledToggle(
              label: strings.music,
              value: controller.musicOn,
              onChanged: (_) => controller.toggleMusic(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressSection(GameController controller, AppLocalizations strings) {
    return SettingsSection(
      title: strings.progress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cocoa.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${controller.discoveredUnlockedItemCount} / ${controller.unlockedItemTotal}',
                  style: AppText.display(
                    size: 20,
                    weight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
                Text(
                  strings.discovered,
                  style: AppText.body(size: 12, color: AppColors.mutedBrown),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ProgressBar(
              value: controller.unlockedProgress,
              trackColor: const Color(0xFFEEE2C8),
              height: 7,
            ),
            const SizedBox(height: 14),
            if (_resetArmed)
              _ResetConfirm(
                strings: strings,
                onConfirm: () {
                  controller.resetProgress();
                  setState(() => _resetArmed = false);
                },
                onCancel: () => setState(() => _resetArmed = false),
              )
            else
              _ResetButton(
                label: strings.reset,
                onTap: () => setState(() => _resetArmed = true),
              ),
          ],
        ),
      ),
    );
  }

  Widget _helpSection(BuildContext context, AppLocalizations strings) {
    return SettingsSection(
      title: strings.help,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cocoa.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            _HelpRow(
              icon: Icons.play_circle_outline_rounded,
              title: strings.howToPlay,
              subtitle: strings.howToPlayBlurb,
              onTap: () => context.push(AppRoutes.intro),
              showDivider: true,
            ),
            _HelpRow(
              icon: Icons.help_outline_rounded,
              title: strings.faq,
              subtitle: strings.faqBlurb,
              onTap: () => context.push(AppRoutes.faq),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutCard(AppLocalizations strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.about,
            style: AppText.display(
              size: 15,
              weight: FontWeight.w700,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.aboutBody,
            style: AppText.body(size: 13, color: AppColors.cocoaSoft, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// A language row: native name (rendered with the platform font so Indic and
/// other scripts display) plus the English name underneath when they differ.
class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          language.nativeName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.cocoa,
          ),
        ),
        if (language.nativeName != language.englishName)
          Text(
            language.englishName,
            style: AppText.body(size: 11, color: AppColors.mutedBrown),
          ),
      ],
    );
  }
}

/// A tappable row inside the Help card.
class _HelpRow extends StatelessWidget {
  const _HelpRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.cocoa.withValues(alpha: 0.07),
                  ),
                ),
              )
            : null,
        child: Row(
          children: <Widget>[
            Icon(icon, size: 22, color: AppColors.spiceBrown),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppText.display(
                      size: 15,
                      weight: FontWeight.w700,
                      color: AppColors.cocoa,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppText.body(size: 12, color: AppColors.mutedBrown),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.mutedBrown),
          ],
        ),
      ),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.brick.withValues(alpha: 0.06),
            border: Border.all(color: AppColors.brick.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: AppText.display(
              size: 14,
              weight: FontWeight.w700,
              color: AppColors.brick,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetConfirm extends StatelessWidget {
  const _ResetConfirm({
    required this.strings,
    required this.onConfirm,
    required this.onCancel,
  });

  final AppLocalizations strings;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: onConfirm,
            child: Container(
              padding: const EdgeInsets.all(11),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brick,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                strings.resetConfirm,
                style: AppText.display(size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onCancel,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cocoa.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.close, size: 18, color: AppColors.cocoa),
          ),
        ),
      ],
    );
  }
}
