# دليل تطبيق: منع تشغيل التطبيق على الأجهزة المروّتة (Root / Jailbreak)

> **الغرض:** هذا الملف مرجع تنفيذي كامل لنقل آلية «حجب التطبيق على الأجهزة
> المروّتة» المطبَّقة في تطبيق **RDB (Ramaaz Digital Bank)** إلى أي تطبيق
> Flutter آخر. سلّم هذا الملف إلى Claude في المشروع الهدف واطلب منه تطبيقه.
>
> **مصدر الحقيقة:** التطبيق الفعلي في RDB — `pubspec.yaml`, `lib/main.dart`,
> `lib/trydos_application.dart`, `lib/features/security/presentation/root_security_issue_page.dart`.

---

## 1. الفكرة بسطر واحد

عند إقلاع التطبيق (قبل عرض أي واجهة فعلية) نفحص الجهاز مرّة واحدة عبر حزمة
`root_check_flutter`. إذا كان الجهاز مروّتاً (Android root / iOS jailbreak)
نعرض **شجرة ويدجت مختلفة كلياً**: شاشة تحذير أمني ثابتة بلا Router وبلا
Deep Links وبلا مؤقّت القفل — أي أن المستخدم لا يصل إلى أي شاشة من التطبيق.

المعمارية المختارة **حجب على مستوى الجذر (root-level gate)** وليس
`Navigator.push` لشاشة تحذير — لأن الدفع يمكن تجاوزه بالرجوع، بينما استبدال
شجرة الويدجت كاملة لا يترك مساراً بديلاً.

---

## 2. الاعتمادية

في `pubspec.yaml` ضمن `dependencies`:

```yaml
dependencies:
  root_check_flutter: ^1.0.5
```

ثم:

```bash
flutter pub get
```

**لا حاجة إلى أي إعداد إضافي:**

- لا صلاحيات (permissions) في `AndroidManifest.xml`.
- لا مفاتيح في `Info.plist`.
- التسجيل يتم تلقائياً عبر `GeneratedPluginRegistrant` في المنصّتين
  (تحقّقنا: `ios/Runner/GeneratedPluginRegistrant.m` و
  `android/.../GeneratedPluginRegistrant.java` يسجّلان الحزمة تلقائياً).

الحزمة تكشف على Android: وجود `su`، تطبيقات إدارة الروت، بناء test-keys،
مسارات نظام قابلة للكتابة. وعلى iOS: مسارات Cydia/Sileo، إمكانية الكتابة
خارج sandbox، مخطّطات URL الخاصة بأدوات الجيلبريك.

---

## 3. الملفات الثلاثة المطلوبة

| # | الملف | الدور |
|---|-------|-------|
| 1 | `lib/main.dart` | تنفيذ الفحص مرّة واحدة أثناء الإقلاع وتمرير النتيجة للأعلى |
| 2 | `lib/features/security/presentation/root_security_issue_page.dart` | شاشة التحذير (جديد) |
| 3 | ويدجت التطبيق الجذري (في RDB: `lib/trydos_application.dart`) | التفريع بين شجرتَي الويدجت |

بالإضافة إلى **3 مفاتيح ترجمة** لكل لغة مدعومة.

---

## 4. الخطوة 1 — الفحص في `main.dart`

الفحص يُنفَّذ داخل ويدجت إقلاع (`_AppBootstrap`) يرسم إطاراً أبيض فوراً
(لإغلاق سبلاش النظام) ثم يُنفّذ التهيئة الثقيلة، ومنها فحص الروت، قبل عرض
التطبيق.

### 4.1 دالة الفحص (أسفل الملف)

```dart
import 'dart:developer' as dev;
import 'package:root_check_flutter/root_check_flutter.dart';

Future<bool> _checkDeviceRooted() async {
  try {
    return await RootCheckFlutter.isDeviceRooted;
  } catch (e, st) {
    dev.log('Root check failed: $e', stackTrace: st);
    return false; // fail-open — انظر §8 «قرارات التصميم»
  }
}
```

### 4.2 حالة ويدجت الإقلاع

```dart
class _AppBootstrapState extends State<_AppBootstrap> {
  bool _ready = false;
  bool _isDeviceRooted = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // ... بقية التهيئة (التخزين، DI، الترجمة، الإشعارات ...) ...

      // فحص الروت: مرّة واحدة فقط، قبل عرض أي واجهة فعلية.
      _isDeviceRooted = await _checkDeviceRooted();
    } catch (e, st) {
      dev.log('App bootstrap failed: $e', stackTrace: st);
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFFFFFFFF)),
          if (_ready)
            MyApplication(                       // ← ويدجت التطبيق الجذري لديك
              navKey: navigatorKey,
              isSecurityIssueFound: _isDeviceRooted,
            ),
        ],
      ),
    );
  }
}
```

> **ملاحظة ترتيب مهمّة:** ضع `_checkDeviceRooted()` **داخل** كتلة `try` بعد
> تهيئة الترجمة (`EasyLocalization.ensureInitialized`) — لأن شاشة التحذير
> تستخدم مفاتيح ترجمة، فإن لم تكن الترجمة جاهزة ستظهر المفاتيح الخام.

> **إذا لم يكن مشروعك يستخدم نمط `_AppBootstrap`:** يكفي جعل `main()` غير
> متزامنة وتنفيذ الفحص قبل `runApp`:
> ```dart
> Future<void> main() async {
>   WidgetsFlutterBinding.ensureInitialized();
>   final isRooted = await _checkDeviceRooted();
>   runApp(MyApplication(isSecurityIssueFound: isRooted));
> }
> ```
> العيب: يؤخّر أول إطار قليلاً (سبلاش النظام يبقى ظاهراً). نمط `_AppBootstrap`
> أفضل للتطبيقات ذات التهيئة الثقيلة.

---

## 5. الخطوة 2 — شاشة التحذير

أنشئ `lib/features/security/presentation/root_security_issue_page.dart`:

```dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RootSecurityIssuePage extends StatelessWidget {
  const RootSecurityIssuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0E1528), Color(0xFF13203E), Color(0xFF0A101E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.16),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.55),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 64,
                    color: Color(0xFFFF7272),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'security_issues_found_title'.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 22.sp, height: 1.6, color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'security_issues_found_message'.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 15.sp, height: 1.6, color: const Color(0xFFB7C6E9),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'security_issues_found_details'.tr(),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 13.sp, height: 1.6, color: const Color(0xFFB7C6E9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**تعديلات حسب مشروعك:**

- إن لم تستخدم `flutter_screenutil`: احذف `.sp` واستخدم أحجاماً ثابتة.
- إن لم تستخدم `easy_localization`: استبدل `'key'.tr()` بنصوص مباشرة أو بنظام
  الترجمة لديك.
- إن كان لديك `LocaleKeys` مولَّد: استخدم `LocaleKeys.security_issues_found_title.tr()`
  بدل النص الحرفي (هذا ما يفعله RDB).
- **لا تضع زر «متابعة» أو «تجاهل»** — الشاشة نهائية بلا مخرج، وهذا هو المقصود.

---

## 6. الخطوة 3 — التفريع في ويدجت التطبيق الجذري

هذه هي النقطة الجوهرية. في ويدجت التطبيق الجذري:

### 6.1 استقبال العَلَم

```dart
class MyApplication extends StatefulWidget {
  const MyApplication({
    super.key,
    required this.navKey,
    required this.isSecurityIssueFound,
  });

  final GlobalKey<NavigatorState> navKey;
  final bool isSecurityIssueFound;

  @override
  State<MyApplication> createState() => _MyApplicationState();
}
```

### 6.2 تعطيل الخدمات الجانبية عند الحجب

في `initState` — لا تُشغّل Deep Links ولا مؤقّت القفل ولا أي خدمة تتفاعل مع
الجلسة، لأن المستخدم لن يصل إلى التطبيق أصلاً:

```dart
@override
void initState() {
  super.initState();
  if (!widget.isSecurityIssueFound) {
    _deepLinkService.init();
    _idleLockTimer.start();
    // ... أي خدمات أخرى مرتبطة بالجلسة ...
  }
}
```

### 6.3 التفريع في `build`

```dart
child: widget.isSecurityIssueFound
    ? MaterialApp(                      // ← بلا Router: لا مسارات إطلاقاً
        debugShowCheckedModeBanner: false,
        color: const Color(0xFFFFFFFF),
        locale: context.locale,
        theme: AppTheme.light,
        darkTheme: AppTheme.light,      // إجبار الوضع الفاتح: ثبات شاشة الأمان
        themeMode: ThemeMode.light,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        home: const RootSecurityIssuePage(),
      )
    : MaterialApp.router(               // ← التطبيق الطبيعي
        debugShowCheckedModeBanner: false,
        color: const Color(0xFFFFFFFF),
        locale: context.locale,
        routerConfig: AppRouter.router,
        theme: AppTheme.light,
        darkTheme: AppTheme.light,
        themeMode: ThemeMode.light,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
      ),
```

**القاعدة الحاسمة:** في فرع الحجب استخدم `MaterialApp` بـ `home:` وليس
`MaterialApp.router`. تمرير `routerConfig` يُبقي جدول المسارات حيّاً، ويمكن
عندها لرابط عميق (deep link) أو `go()` أن يخرج من شاشة التحذير.

---

## 7. الخطوة 4 — مفاتيح الترجمة

أضف هذه المفاتيح لكل ملف لغة (في RDB: `assets/languages/*.json`):

**العربية `ar.json`:**
```json
"security_issues_found_title": "تم اكتشاف مشاكل أمنية",
"security_issues_found_message": "لا يمكن فتح التطبيق لأن جهازك يبدو أنه مروّت أو غير آمن.",
"security_issues_found_details": "لحمايتك ولحماية حسابك وعملياتك، يرجى إزالة صلاحيات الروت ثم إعادة المحاولة."
```

**الإنجليزية `en.json`:**
```json
"security_issues_found_title": "Security Issues Found",
"security_issues_found_message": "This app cannot be opened because your device appears to be rooted or compromised.",
"security_issues_found_details": "For your safety and to protect your account and transactions, please remove root access and try again."
```

**التركية `tr.json`:**
```json
"security_issues_found_title": "Güvenlik Sorunları Bulundu",
"security_issues_found_message": "Cihazınız rootlu veya güvenliği ihlal edilmiş göründüğü için bu uygulama açılamaz.",
"security_issues_found_details": "Güvenliğiniz ve hesap işlemlerinizin korunması için lütfen root erişimini kaldırıp tekrar deneyin."
```

**الكردية `ku.json`:**
```json
"security_issues_found_title": "کێشەی ئەمنی دۆزرایەوە",
"security_issues_found_message": "ئەم ئەپە ناکرێت بکرێتەوە چونکە ئامێرەکەت روتکراو یان ناسەقامگیر دیارە.",
"security_issues_found_details": "بۆ پاراستنی تۆ و هەژمار و مامەڵەکانت، تکایە دەسەڵاتی روت لاببە و دووبارە هەوڵبدە."
```

إن كنت تستخدم توليد `LocaleKeys` (easy_localization codegen) فأعد التوليد بعد
الإضافة. **لا تُحرّر الملفات المولَّدة يدوياً.**

---

## 8. قرارات التصميم (مهمّة — لا تغيّرها دون قصد)

| القرار | السبب |
|--------|-------|
| **Fail-open** عند رمي استثناء (`return false`) | خلل في الحزمة على جهاز سليم يجب ألّا يحجب مستخدماً شرعياً. إن كان تطبيقك يفضّل الأمان على التوافر، غيّرها إلى `return true` — وتحمّل خطر حجب مستخدمين شرعيين. |
| **الفحص مرّة واحدة عند الإقلاع فقط** | الروت لا يُفعَّل أثناء تشغيل التطبيق عملياً؛ الفحص المتكرّر يكلّف أداءً بلا مقابل. |
| **استبدال شجرة الويدجت** بدل `Navigator.push` | لا يترك أي مسار رجوع أو تجاوز. |
| **إجبار الوضع الفاتح** في فرع الحجب | ثبات مظهر شاشة الأمان بغضّ النظر عن إعداد النظام. |
| **تعطيل Deep Links عند الحجب** | رابط عميق يمكنه تجاوز شاشة التحذير إن بقيت الخدمة نشطة. |
| **لا زر خروج/متابعة** | الحجب نهائي بالتصميم. |

---

## 9. حدود هذه الحماية (اذكرها للفريق)

- **الكشف على العميل قابل للتجاوز.** أدوات مثل Magisk Hide / Zygisk /
  Shamiko تُخفي الروت عن هذا النوع من الفحوص. هذه طبقة **ردع**، لا حاجز مطلق.
- **ليست بديلاً عن الحماية على الخادم.** المنطق الحسّاس (التحقّق من الهوية،
  حدود العمليات، صلاحيات الحساب) يجب أن يُفرَض على الـ backend.
- **للحاجات الأعلى** فكّر في `Play Integrity API` (Android) و
  `DeviceCheck / App Attest` (iOS) مع تحقّق على الخادم، أو حل تجاري مثل
  freeRASP. الآلية الموصوفة هنا هي الطبقة الأولى فقط.
- **المحاكيات (Emulators)** غالباً تُكشف كأجهزة مروّتة — انتبه لأثر ذلك على
  فِرَق QA وأتمتة الاختبار.

---

## 10. الاختبار

| الحالة | الطريقة | النتيجة المتوقّعة |
|--------|---------|-------------------|
| جهاز سليم | هاتف فعلي غير مروّت | التطبيق يفتح طبيعياً |
| جهاز مروّت (Android) | محاكي بصورة AOSP/rooted أو جهاز بـ Magisk | شاشة التحذير فقط، لا وصول لأي شاشة |
| iOS مجيلبرك | جهاز مجيلبرك أو محاكي | شاشة التحذير |
| فشل الحزمة | افرض استثناءً مؤقتاً داخل `_checkDeviceRooted` | التطبيق يفتح طبيعياً (fail-open) + سطر في اللوج |
| Deep Link أثناء الحجب | افتح رابطاً عميقاً بينما الجهاز مروّت | لا شيء يحدث — تبقى شاشة التحذير |
| الترجمة | بدّل لغة الجهاز | نصوص الشاشة تتبع اللغة، لا تظهر مفاتيح خام |

**اختبار محلي سريع بلا جهاز مروّت:** استبدل جسم `_checkDeviceRooted` مؤقتاً
بـ `return true;` وتأكّد أن شاشة التحذير تظهر وأن لا مسار يخرج منها — ثم
أعِد الكود الأصلي.

---

## 11. قائمة تحقّق للتنفيذ

- [ ] إضافة `root_check_flutter: ^1.0.5` إلى `pubspec.yaml` + `flutter pub get`
- [ ] إضافة `_checkDeviceRooted()` في `main.dart` مع `try/catch` و fail-open
- [ ] استدعاء الفحص في تسلسل الإقلاع **بعد** تهيئة الترجمة
- [ ] تمرير النتيجة كـ `isSecurityIssueFound` إلى ويدجت التطبيق الجذري
- [ ] إنشاء `root_security_issue_page.dart`
- [ ] التفريع في `build`: `MaterialApp` + `home:` عند الحجب / `MaterialApp.router` عادةً
- [ ] حراسة `initState` — لا Deep Links ولا مؤقّت قفل عند الحجب
- [ ] إضافة مفاتيح الترجمة الثلاثة لكل لغة + إعادة توليد `LocaleKeys` إن وُجد
- [ ] تشغيل `flutter analyze` (صفر أخطاء)
- [ ] تنفيذ حالات الاختبار في §10
- [ ] توثيق الحدود في §9 لفريق الأمان/المنتج

---

## 12. تعليمات مباشرة لـ Claude في المشروع الهدف

> اقرأ هذا الملف بالكامل، ثم:
> 1. افحص المشروع أولاً: هل يستخدم `easy_localization`؟ `flutter_screenutil`؟
>    `go_router` أم `Navigator`؟ ما اسم ويدجت التطبيق الجذري وأين `main()`؟
> 2. طبّق الخطوات §4 → §7 **مُكيَّفة** على أنماط المشروع الهدف، لا نسخاً حرفياً
>    (خصوصاً `LocaleKeys`, `AppTheme`, `context.textTheme`, أسماء الخدمات).
> 3. **لا تنشئ شجرة حالة موازية** ولا BLoC جديداً لهذا — النتيجة قيمة
>    `bool` واحدة تُمرَّر بالمُنشئ.
> 4. لا تُعدّل أي ملف مولَّد (`*.g.dart`, `GeneratedPluginRegistrant.*`) —
>    أعِد التوليد بدلاً من ذلك.
> 5. أنهِ بـ `flutter analyze` وأبلغ عن الملفات التي عدّلتها.
