import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/external_links.dart';
import '../../../data/app_update_repository.dart';
import 'package:mixrun/l10n/gen/app_localizations.dart';

/// Shows the "new version" overlay for [status] and snoozes it if dismissed.
///
/// A *required* update cannot be dismissed: the barrier, the back gesture and
/// the Later button are all gone, so the only way forward is the download. An
/// *optional* one can be put off, which silences it for
/// [AppUpdateRepository.snoozeFor] unless a newer build is published first.
///
/// Does nothing when [status] says the app is current, so callers can hand over
/// a check result without inspecting it.
Future<void> showUpdatePrompt(
  BuildContext context,
  UpdateStatus status, {
  required AppUpdateRepository repository,
}) async {
  final AppRelease? release = status.release;
  if (!status.shouldPrompt || release == null) return;

  final bool required = status.isRequired;
  final bool? updated = await showDialog<bool>(
    context: context,
    barrierDismissible: !required,
    barrierColor: AppColors.cocoa.withValues(alpha: 0.45),
    builder: (BuildContext context) => _UpdateDialog(
      release: release,
      required: required,
    ),
  );

  // Dismissed rather than acted on: don't ask again for a while. Required
  // updates never reach here, since the dialog cannot be dismissed.
  if (updated != true && !required) {
    await repository.snooze(release);
  }
}

/// The card inside the update overlay: what's new and a download call to
/// action, styled to match the app's light "Utsav" surfaces.
class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog({required this.release, required this.required});

  final AppRelease release;
  final bool required;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  /// Set when the handoff to the browser failed, so the player is told rather
  /// than left tapping a button that appears to do nothing.
  bool _failed = false;

  Future<void> _download() async {
    final bool opened = await openDownload(widget.release.downloadUrl);
    if (!mounted) return;
    if (!opened) {
      setState(() => _failed = true);
      return;
    }
    // A required update keeps the overlay up: the player has to come back with
    // the new build installed, not to the old one still running.
    if (!widget.required) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final String version = widget.release.versionName;
    final String? notes = widget.release.notes;

    return PopScope(
      canPop: !widget.required,
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.system_update_rounded,
                size: 34,
                color: AppColors.gold,
              ),
              const SizedBox(height: 14),
              Text(
                widget.required
                    ? strings.updateRequiredTitle
                    : strings.updateTitle,
                textAlign: TextAlign.center,
                style: AppText.display(
                  size: 20,
                  weight: FontWeight.w800,
                  color: AppColors.cocoa,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.required
                    ? strings.updateRequiredBody(version)
                    : strings.updateBody(version),
                textAlign: TextAlign.center,
                style: AppText.body(size: 14, color: AppColors.mutedBrown),
              ),
              if (notes != null) ...<Widget>[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.parchmentBottom,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    notes,
                    style: AppText.body(
                      size: 13,
                      color: AppColors.cocoaSoft,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
              if (_failed) ...<Widget>[
                const SizedBox(height: 14),
                Text(
                  strings.updateFailed,
                  textAlign: TextAlign.center,
                  style: AppText.body(size: 13, color: AppColors.brick),
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  if (!widget.required) ...<Widget>[
                    Expanded(
                      child: _DialogButton(
                        label: strings.updateLater,
                        onTap: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: _DialogButton(
                      label: strings.updateNow,
                      filled: true,
                      onTap: _download,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A pill button for the update overlay: outlined to defer, filled saffron to
/// download.
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
          color: filled ? AppColors.gold : Colors.white,
          border: Border.all(
            color: filled
                ? AppColors.gold
                : AppColors.cocoa.withValues(alpha: 0.15),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: AppText.display(
            size: 15,
            weight: FontWeight.w700,
            color: filled ? AppColors.onGold : AppColors.cocoa,
          ),
        ),
      ),
    );
  }
}
