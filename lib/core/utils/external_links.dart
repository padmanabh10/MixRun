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
