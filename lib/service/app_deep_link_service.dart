import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/core/utils/app_lock_overlay.dart';
import 'package:rdb/routes/router.dart';
import 'package:trydos_wallet/trydos_wallet.dart';

class AppDeepLinkService {
  /// المضيفات المسموحة تأتي من `DEEPLINK_ALLOWED_HOSTS` في `.env` (قائمة
  /// مفصولة بفواصل) لتبقى **مصدراً واحداً** متوافقاً مع ما تسجّله المنصّات:
  /// `android/app/src/main/AndroidManifest.xml` و`ios/Runner/Runner.entitlements`.
  /// أي مضيف يُضاف في المنصّتين ولا يُضاف هنا تُتجاهَل روابطه بصمت.
  ///
  /// الاحتياطي أدناه يطابق ما كان مثبّتاً في الكود سابقاً، ليبقى السلوك معرّفاً
  /// إن غاب المتغيّر عن البيئة.
  static const List<String> _fallbackAllowedHosts = <String>[
    'rdb-ms.yazan-adnof.workers.dev',
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

  /// رابط وصل والتطبيق خلف القفل؛ يُسلَّم فور فكّه. آخر رابط يفوز: إن وصل
  /// رابطان قبل فكّ القفل فالأخير هو ما ينظر إليه المستخدم.
  Uri? _pendingUri;
  Timer? _lockPoll;
  bool _lockWatchArmed = false;

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
    _disarmLockWatch();
    _pendingUri = null;
    await _subscription?.cancel();
  }

  /// **لا يُعالَج أي رابط عميق قبل تجاوز طبقة القفل.** الرابط قد يفتح شاشة دفع
  /// تعرض الأرصدة وتحرّك مالاً، فتسليمه قبل رمز المرور/الـ passkey كان يسمح لمن
  /// يمسك الهاتف بتجاوز القفل عبر رابط. نحتجزه هنا ونسلّمه بعد فكّ القفل.
  void _handleUri(Uri? uri) {
    if (uri == null) {
      return;
    }

    if (_isLocked) {
      _pendingUri = uri;
      _armLockWatch();
      debugPrint('Deep link held behind the lock: ${uri.host}${uri.path}');
      return;
    }

    _deliver(uri);
  }

  void _deliver(Uri uri) {
    // روابط الدفع تُسلَّم لمكتبة المحفظة **قبل أي فلترة** وبأي مضيف كان: هي
    // تتحقّق من شكل الكود محلياً قبل أي نداء شبكة، فتمرير رابط لا يخصّها بلا
    // كلفة. وفلترتنا المسبقة كانت ستستهلك حدّ المحاولات (10/15 دقيقة) أو تُسقط
    // روابط صحيحة إن تغيّر شكلها. ترجع true إن كان رابط دفع وتكفّلت به، فتفتح
    // شاشة الدفع بنفسها — وإن لم تكن واجهة المحفظة جاهزة بعد (إقلاع بارد أو
    // المستخدم لم يسجّل دخوله) تحتفظ بالكود وتعيده فور جهوزها.
    if (TrydosWallet.handleIncomingLink(uri)) {
      debugPrint('Deep link taken by wallet: ${uri.host}${uri.path}');
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

  /// هل التطبيق خلف طبقة القفل الآن؟ نكرّر شرط [AppLockController] نفسه: القفل
  /// لا يظهر أصلاً بلا جلسة قائمة ورمز مرور مضبوط (المستخدم الجديد لا يُحتجز
  /// رابطه بلا نهاية). ونقرأ `shouldShowPin` كذلك لأن السبلاش يضبطه قبل أن
  /// يزامن الـ controller حالته، فالإقلاع البارد يمرّ بلحظة يكون فيها القفل
  /// قادماً ولم يظهر بعد — وهي اللحظة التي كان الرابط يمرّ فيها.
  bool get _isLocked {
    try {
      final prefs = GetIt.I<PrefsRepository>();
      final hasSession = (prefs.walletToken ?? '').isNotEmpty;
      final hasPasscode = (prefs.passcode ?? '').isNotEmpty;
      if (!hasSession || !hasPasscode) {
        return false;
      }
      final lock = AppLockController.instance;
      return !lock.isPasscodeVerified.value ||
          lock.isShowSwitch.value ||
          (prefs.shouldShowPin ?? false);
    } catch (e) {
      // الـ DI ليس جاهزاً بعد (رابط سبق configureDependencies): اعتبره مقفولاً
      // ثم أعد الفحص — الاحتجاز آمن، والتسليم المبكر ليس كذلك.
      return true;
    }
  }

  void _armLockWatch() {
    if (!_lockWatchArmed) {
      _lockWatchArmed = true;
      AppLockController.instance.isPasscodeVerified.addListener(_onLockChanged);
      AppLockController.instance.isShowSwitch.addListener(_onLockChanged);
    }
    // شبكة أمان: فكّ القفل عبر `shouldShowPin` أو جهوز الـ DI لا يُطلق أي حدث
    // من الـ notifiers، فنعيد الفحص دورياً ما دام هناك رابط محتجَز فقط.
    _lockPoll ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => _onLockChanged(),
    );
  }

  void _onLockChanged() {
    final uri = _pendingUri;
    if (uri == null) {
      _disarmLockWatch();
      return;
    }
    if (_isLocked) {
      return;
    }
    _pendingUri = null;
    _disarmLockWatch();
    debugPrint('Lock cleared — releasing deep link: ${uri.host}${uri.path}');
    _deliver(uri);
  }

  void _disarmLockWatch() {
    _lockPoll?.cancel();
    _lockPoll = null;
    if (_lockWatchArmed) {
      _lockWatchArmed = false;
      AppLockController.instance.isPasscodeVerified.removeListener(
        _onLockChanged,
      );
      AppLockController.instance.isShowSwitch.removeListener(_onLockChanged);
    }
  }
}
