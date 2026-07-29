import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';
import '../../../data/audio_service.dart';
import '../../../domain/game_controller.dart';

/// The persistent frame around the four in-game sections (canvas, encyclopedia,
/// stats, settings). It hosts the bottom toolbar that stays put while the
/// player moves between sections, and keeps each section's state alive.
///
/// Pressing back from a section returns to the canvas; pressing back from the
/// canvas itself asks for confirmation before leaving the game.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Handles a system back press. From a section we hop back to the canvas;
  /// from the canvas we confirm before exiting so a stray swipe can't drop the
  /// player out of the game.
  Future<void> _onBack(BuildContext context, int index) async {
    if (index != 0) {
      navigationShell.goBranch(0);
      return;
    }
    final bool exit = await _confirmExit(context);
    if (exit) await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final GameController controller = context.watch<GameController>();
    final AudioService audio = context.read<AudioService>();
    final AppLocalizations strings = AppLocalizations.of(context);
    final int index = navigationShell.currentIndex;

    return PopScope(
      // Never pop automatically: a section returns to the canvas, and the
      // canvas shows an exit-confirmation overlay first (see [_onBack]).
      canPop: false,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) _onBack(context, index);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: _Toolbar(
          strings: strings,
          activeIndex: index,
          canRevert: controller.canRevertClear,
          showJourney: controller.isJourneyUnlocked,
          onClear: () {
            audio.playEffect(Sfx.clear);
            controller.clearCanvas();
          },
          onRevert: () {
            audio.playEffect(Sfx.revert);
            controller.revertClear();
          },
          onHint: () => navigationShell.goBranch(4),
          onCanvas: () => navigationShell.goBranch(0),
          onEncyclopedia: () => navigationShell.goBranch(1),
          onJourney: () => navigationShell.goBranch(5),
          onStats: () => navigationShell.goBranch(2),
          onSettings: () => navigationShell.goBranch(3),
        ),
      ),
    );
  }
}

/// Shows the "exit game?" overlay and resolves to whether the player confirmed.
///
/// Returns `false` when dismissed by tapping outside or the back gesture, so a
/// hesitant player always stays in the game.
Future<bool> _confirmExit(BuildContext context) async {
  final AppLocalizations strings = AppLocalizations.of(context);
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.cocoa.withValues(alpha: 0.45),
    builder: (BuildContext context) => _ExitDialog(strings: strings),
  );
  return result ?? false;
}

/// The confirmation card inside the exit overlay: a question and a Stay / Exit
/// choice, styled to match the app's light "Utsav" surfaces.
class _ExitDialog extends StatelessWidget {
  const _ExitDialog({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              strings.exitGameTitle,
              textAlign: TextAlign.center,
              style: AppText.display(
                size: 20,
                weight: FontWeight.w800,
                color: AppColors.cocoa,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              strings.exitGameBody,
              textAlign: TextAlign.center,
              style: AppText.body(size: 14, color: AppColors.mutedBrown),
            ),
            const SizedBox(height: 22),
            Row(
              children: <Widget>[
                Expanded(
                  child: _DialogButton(
                    label: strings.stay,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DialogButton(
                    label: strings.exitGame,
                    filled: true,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A pill button for the exit overlay: outlined for the safe choice, filled
/// terracotta for the confirming one.
class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? AppColors.brick : Colors.white,
          border: Border.all(
            color: filled
                ? AppColors.brick
                : AppColors.cocoa.withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: AppText.display(
            size: 15,
            weight: FontWeight.w700,
            color: filled ? Colors.white : AppColors.cocoa,
          ),
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.strings,
    required this.activeIndex,
    required this.canRevert,
    required this.showJourney,
    required this.onClear,
    required this.onRevert,
    required this.onHint,
    required this.onCanvas,
    required this.onEncyclopedia,
    required this.onJourney,
    required this.onStats,
    required this.onSettings,
  });

  final AppLocalizations strings;
  final int activeIndex;
  final bool canRevert;

  /// Whether the Journey button is shown,  hidden until States & UTs unlocks.
  final bool showJourney;
  final VoidCallback onClear;
  final VoidCallback onRevert;
  final VoidCallback onHint;
  final VoidCallback onCanvas;
  final VoidCallback onEncyclopedia;
  final VoidCallback onJourney;
  final VoidCallback onStats;
  final VoidCallback onSettings;

  /// A section navigation button. When its section is the active one it turns
  /// into a close (X) that returns to the canvas.
  Widget _navButton(IconData icon, String label, int branch, VoidCallback onOpen) {
    final bool active = activeIndex == branch;
    return _ToolButton(
      icon: active ? Icons.close_rounded : icon,
      label: active ? strings.close : label,
      onTap: active ? onCanvas : onOpen,
      active: active,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(6, 8, 6, 8 + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.cocoa.withValues(alpha: 0.07)),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.cocoa.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // Clear/revert supply their own distinct sounds, so suppress the
          // generic tap click here to avoid doubling up.
          if (canRevert)
            _ToolButton(icon: Icons.undo_rounded, label: strings.revert, onTap: onRevert, accent: true, clickSound: false)
          else
            _ToolButton(icon: Icons.cleaning_services_rounded, label: strings.clear, onTap: onClear, clickSound: false),
          // Each section's button turns into a close (X) while that section is
          // open, returning the player to the canvas.
          _navButton(Icons.menu_book_rounded, strings.encyclopedia, 1, onEncyclopedia),
          if (showJourney)
            _navButton(Icons.route_rounded, strings.journey, 5, onJourney),
          _navButton(Icons.bar_chart_rounded, strings.stats, 2, onStats),
          _navButton(Icons.tune_rounded, strings.settings, 3, onSettings),
          _navButton(Icons.lightbulb_rounded, strings.hint, 4, onHint),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
    this.active = false,
    this.clickSound = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;
  final bool active;

  /// Whether tapping plays the generic UI click. Off for buttons that already
  /// play their own effect (clear/revert).
  final bool clickSound;

  @override
  Widget build(BuildContext context) {
    final Color color = active
        ? AppColors.spiceBrown
        : accent
            ? AppColors.orange
            : AppColors.mutedBrown;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (clickSound) context.read<AudioService>().playEffect(Sfx.button);
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(
                  size: 9.5,
                  weight: active ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
