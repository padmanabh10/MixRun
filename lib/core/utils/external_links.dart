import 'dart:developer' as developer;

import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in the device's browser.
///
/// Failures are logged rather than thrown so a broken link never crashes a
/// learning moment.
Future<void> openArticle(String url) async {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (error, stackTrace) {
    developer.log(
      'Could not open article',
      name: 'mixrun.links',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Opens [url] so the device downloads it.
///
/// Used for the APK of a new release: handing the URL to the browser lets
/// Android's own download manager fetch it and offer to install, which needs no
/// extra permission from us.
///
/// Returns whether the handoff succeeded, so the caller can leave an update
/// prompt on screen when nothing opened.
Future<bool> openDownload(String url) async {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (error, stackTrace) {
    developer.log(
      'Could not open download',
      name: 'mixrun.links',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

/// Opens the device's mail composer addressed to [address], optionally
/// pre-filling [subject].
///
/// Failures are logged rather than thrown so a missing mail client never
/// crashes the screen.
Future<void> openEmail(String address, {String? subject}) async {
  final Uri uri = Uri(
    scheme: 'mailto',
    path: address,
    query: subject == null
        ? null
        : 'subject=${Uri.encodeComponent(subject)}',
  );
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (error, stackTrace) {
    developer.log(
      'Could not open mail client',
      name: 'mixrun.links',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
