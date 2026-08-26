import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rdb/routes/router.dart';

class AppDeepLinkService {
  /// المضيفات المسموحة تأتي من `DEEPLINK_ALLOWED_HOSTS` في `.env` (قائمة
  /// مفصولة بفواصل) لتبقى **مصدراً واحداً** متوافقاً مع ما تسجّله المنصّات:
  /// `android/app/src/main/AndroidManifest.xml` و`ios/Runner/Runner.entitlements`.
  /// أي مضيف يُضاف في المنصّتين ولا يُضاف هنا تُتجاهَل روابطه بصمت.
  ///
  /// الاحتياطي أدناه يطابق ما كان مثبّتاً في الكود سابقاً، ليبقى السلوك معرّفاً
  /// إن غاب المتغيّر عن البيئة.
  static const List<String> _fallbackAllowedHosts = <String>[
    'staging-ramaaz-digital-banking.yazan-adnof.workers.dev',
  ];

  static Set<String> get allowedHosts {
    // dotenv.env يرمي NotInitializedError قبل load()، ورابط الإقلاع البارد قد
    // يصل مبكراً — لذلك نسقط على الاحتياطي بدل أن نُسقط التطبيق.
    final raw = dotenv.isInitialized
        ? (dotenv.env['DEEPLINK_ALLOWED_HOSTS'] ?? '')
        : '';
    final hosts = raw
        .split(',')
        .map((h) => h.trim().toLowerCase())
        .where((h) => h.isNotEmpty)
        .toSet();
    return hosts.isNotEmpty ? hosts : _fallbackAllowedHosts.toSet();
  }

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

    if (!allowedHosts.contains(uri.host.toLowerCase())) {
      debugPrint('Deep link rejected: host "${uri.host}" is not allowed');
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
