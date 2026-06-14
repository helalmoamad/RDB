import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/features/authentication/presentation/pages/pin_code_verify_page.dart';
import 'package:rdb/features/authentication/presentation/pages/switch_between_web_app_page.dart';
import 'package:rdb/main.dart' show navigatorKey;
import 'package:shimmer/shimmer.dart';

/// يدير طبقة الحماية (قفل رمز المرور + شاشة التبديل) كـ **route فوق الـ root
/// navigator** بدلاً من رسمها داخل شجرة ودجت الشاشة الرئيسية.
///
/// لماذا route على الـ root navigator؟
///  - يغطّي **جميع** المسارات (الرئيسية والداخلية مثل KYC/تفاصيل الحساب
///    والمنبثقة) لأنه دائماً الأعلى في المكدّس.
///  - تعمل [PinCodeVerifyPage] كصفحة عادية تماماً، فلوحة مفاتيح الـ PIN
///    المخصّصة وتدفّق "نسيت رمز المرور" (`Navigator.of(context).push`) يعملان
///    طبيعياً وزر الرجوع الصلب يُعالَج أصلاً — بلا Navigator متداخل (الذي كان
///    يسبّب شاشة سوداء وتعارض GlobalKey).
///
/// منطق *متى نقفل/نفك* يبقى في `HomePage` كما كان؛ هنا فقط نخزّن الحالة وندفع/
/// نُزيل الـ route.
class AppLockController {
  AppLockController._();
  static final AppLockController instance = AppLockController._();

  /// تُستخدم لعرض/إخفاء صورة الخلفية في `HomePage` خلف القفل (سلوك قديم).
  final ValueNotifier<bool> isPasscodeVerified = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isShowSwitch = ValueNotifier<bool>(false);

  Route<void>? _gateRoute;

  /// لا تظهر طبقة الحماية إطلاقاً على صفحات الـ auth: تتطلّب جلسة مكتملة
  /// (walletToken + passcode مضبوط). بهذا لا يظهر القفل أبداً قبل تسجيل الدخول
  /// أو على صفحة تعيين الرمز (حيث الـ passcode لم يُضبَط بعد).
  bool get _canShowGate {
    final prefs = GetIt.I<PrefsRepository>();
    return (prefs.walletToken ?? '').isNotEmpty &&
        (prefs.passcode ?? '').isNotEmpty;
  }

  bool get _needsGate =>
      _canShowGate && (!isPasscodeVerified.value || isShowSwitch.value);

  // ── واجهة التحكّم (تُستدعى من HomePage) ──

  void showLock() {
    isPasscodeVerified.value = false;
    _ensureGate();
  }

  void dismissLock() {
    GetIt.I<PrefsRepository>().setShouldShowPin(false);
    isPasscodeVerified.value = true;
    _syncGate();
  }

  void showSwitch() {
    isShowSwitch.value = true;
    _ensureGate();
  }

  void dismissSwitch() {
    final prefs = GetIt.I<PrefsRepository>();
    prefs.setShouldShowSwitch(false);
    // تصفير عدّاد الوقت عند إغلاق switch
    prefs.setSwitchShownAtMs(null);
    isShowSwitch.value = false;
    _syncGate();
  }

  /// مزامنة الحالة من التخزين (الإقلاع البارد / العودة من الخلفية).
  void syncFromPrefs() {
    final prefs = GetIt.I<PrefsRepository>();
    isPasscodeVerified.value = !(prefs.shouldShowPin ?? false);
    isShowSwitch.value = prefs.shouldShowSwitch ?? false;
    _syncGate();
  }

  /// تنظيف عند تسجيل الخروج (الـ go() يكون قد أزال الـ route فعلياً).
  void reset() {
    isPasscodeVerified.value = true;
    isShowSwitch.value = false;
    _gateRoute = null;
  }

  // ── إدارة الـ route ──

  void _syncGate() => _needsGate ? _ensureGate() : _removeGate();

  void _ensureGate() {
    // نؤجّل للإطار التالي حتى يتم الدفع بعد أي `go()` يحدث في نفس دورة العودة
    // من الخلفية (وإلا قد يُزيل go() الـ route فور دفعه).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_needsGate) return;
      if (_gateRoute != null && _gateRoute!.isActive) return;
      _gateRoute = null;
      final nav = navigatorKey.currentState;
      if (nav == null) return; // الـ navigator غير جاهز — سيُعاد عند الحدث التالي
      final route = PageRouteBuilder<void>(
        opaque: false, // اترك ما تحته يُرسم حتى يعمل تأثير الضبابية
        barrierDismissible: false,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const _ProtectionGate(),
      );
      _gateRoute = route;
      nav.push(route);
    });
    // مهم: إن وصل الحدث والتطبيق خامل (لا إطار مجدوَل)، فلن يُنفَّذ الـ
    // postFrameCallback حتى تفاعل لاحق (مثل الرجوع). نُجبر جدولة إطار فوراً
    // ليظهر القفل/التبديل لحظة وصول الحدث في أي صفحة.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _removeGate() {
    final route = _gateRoute;
    _gateRoute = null;
    if (route != null && route.isActive) {
      navigatorKey.currentState?.removeRoute(route);
    }
  }
}

/// محتوى الـ route: يعرض شاشة التبديل أو القفل تفاعلياً (للتبديل أولوية كما في
/// التصميم القديم)، ويختفي عند فك القفل ريثما يُزيله [AppLockController].
class _ProtectionGate extends StatelessWidget {
  const _ProtectionGate();

  @override
  Widget build(BuildContext context) {
    final c = AppLockController.instance;
    return ValueListenableBuilder<bool>(
      valueListenable: c.isShowSwitch,
      builder: (context, showSwitch, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: c.isPasscodeVerified,
          builder: (context, verified, _) {
            if (verified && !showSwitch) return const SizedBox.shrink();
            final Widget foreground = showSwitch
                ? SwitchWepAppPage(onSuccess: c.dismissSwitch)
                : PinCodeVerifyPage(onSuccess: c.dismissLock);
            // الصورة خلف الضبابية → تظهر متزامنة تماماً مع القفل وفوق كل
            // المسارات (الرئيسية والداخلية) لأنها جزء من نفس الـ route.
            return Stack(
              alignment: Alignment.center,
              children: [
                const _LockBackgroundImage(),
                _BlurBarrier(child: foreground),
              ],
            );
          },
        );
      },
    );
  }
}

/// صورة المستخدم خلف القفل (مطابقة للسلوك القديم في HomePage)، لكنها الآن جزء
/// من route القفل فتظهر متزامنة معه وفوق جميع المسارات.
class _LockBackgroundImage extends StatelessWidget {
  const _LockBackgroundImage();

  @override
  Widget build(BuildContext context) {
    final photo = GetIt.I<PrefsRepository>().photo ?? '';
    if (photo.isEmpty) return const SizedBox.shrink();
    return Positioned(
      top: 120.h,
      child: Container(
        width: 200.w,
        height: 200.h,
        decoration: BoxDecoration(
          color: const Color(0xff1D1D1D),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Image.network(
          photo,
          width: 200.w,
          height: 200.h,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) =>
              loadingProgress == null
              ? child
              : Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 200.w,
                    height: 200.h,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

/// خلفية ضبابية تملأ الشاشة وتلتقط كل اللمسات حتى لا يتفاعل المستخدم مع
/// المحتوى الحسّاس تحتها.
class _BlurBarrier extends StatelessWidget {
  const _BlurBarrier({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque, // التقاط كل اللمسات غير المعالَجة
      onTap: () {},
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: SizedBox(
          width: 1.sw,
          height: 1.sh,
          child: child,
        ),
      ),
    );
  }
}
