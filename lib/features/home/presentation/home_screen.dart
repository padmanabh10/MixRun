import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../data/app_update_repository.dart';
import '../../shared/widgets/gold_button.dart';
import '../../shared/widgets/update_dialog.dart';

/// The landing screen: branding and a single call to action.
///
/// Also where a new release announces itself: this is the first screen after the
/// splash, so the check runs here rather than blocking startup.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // After the first frame, so the branding is on screen before anything is
    // laid over it.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  /// Prompts if a newer APK has been published. Runs once per launch, not on
  /// every return to the home screen.
  Future<void> _checkForUpdate() async {
    final AppUpdateRepository updates = context.read<AppUpdateRepository>();
    if (updates.checkedThisSession) return;
    final UpdateStatus status = await updates.check();
    if (!mounted || !status.shouldPrompt) return;
    await showUpdatePrompt(context, status, repository: updates);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.logoCanvas),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 14),
              Expanded(child: _Branding(strings: strings)),
              _Actions(strings: strings),
            ],
          ),
        ),
      ),
    );
  }
}

class _Branding extends StatelessWidget {
  const _Branding({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    // Centered exactly as before in portrait; if the available height is too
    // small (landscape) the content scrolls instead of overflowing. The
    // min-height keeps it vertically centered whenever it does fit.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset('assets/images/mortar.png',
                      width: 116, height: 116),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Image.asset('assets/images/logo.png',
                        fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.tagline,
                    style: AppText.body(
                      size: 15,
                      weight: FontWeight.w500,
                      color: AppColors.cream.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
      child: GoldButton(
        solid: true,
        label: strings.play,
        onPressed: () => context.go(AppRoutes.game),
        leading: const Icon(
          Icons.play_arrow_rounded,
          color: AppColors.onGold,
          size: 26,
        ),
      ),
    );
  }
}
