import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:rdb/routes/router.dart';

class AppDeepLinkService {
  static const String _allowedHost =
      'staging-ramaaz-digital-banking.yazan-adnof.workers.dev';

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      _handleUri(initialUri);
    } catch (e) {
      debugPrint('Deep link initial parse failed: $e');
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object error) {
        debugPrint('Deep link stream error: $error');
      },
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  void _handleUri(Uri? uri) {
    if (uri == null) {
      return;
    }

    if (uri.host.toLowerCase() != _allowedHost) {
      return;
    }

    const String location = '/';

    try {
      GRouter.router.go(location);
    } catch (e) {
      debugPrint('Deep link navigation failed, redirecting to root: $e');
      GRouter.router.go('/');
    }
  }
}
