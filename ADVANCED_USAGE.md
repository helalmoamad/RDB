## 🔧 أمثلة الاستخدام المتقدمة (Advanced Usage)

### مثال 1: استدعاء Manual للحماية

```dart
import 'package:rdb/services/security_service.dart';

class SensitiveDataPage extends StatefulWidget {
  @override
  _SensitiveDataPageState createState() => _SensitiveDataPageState();
}

class _SensitiveDataPageState extends State<SensitiveDataPage> {
  @override
  void initState() {
    super.initState();
    // تفعيل الحماية مباشرة عند دخول الصفحة
    // (بالإضافة للحماية التلقائية من lifecycle)
    _enableSecurityManually();
  }

  Future<void> _enableSecurityManually() async {
    await SecurityService.instance.hideContent();
  }

  @override
  void dispose() {
    // إعادة عرض المحتوى عند مغادرة الصفحة
    SecurityService.instance.showContent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('بيانات حساسة')),
      body: Container(
        child: Text('معلومات حساسة جداً هنا'),
      ),
    );
  }
}
```

---

### مثال 2: دمج مع Feature معينة

```dart
/// في صفحة تسجيل الدخول (حماية كلمة المرور)
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late FocusNode _passwordFocusNode;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _passwordFocusNode.addListener(_onPasswordFocusChange);
  }

  void _onPasswordFocusChange() {
    if (_passwordFocusNode.hasFocus) {
      // عند كتابة كلمة المرور، فعّل الحماية الإضافية
      SecurityService.instance.hideContent();
    } else {
      // عند مغادرة حقل كلمة المرور
      SecurityService.instance.showContent();
    }
  }

  @override
  void dispose() {
    _passwordFocusNode.removeListener(_onPasswordFocusChange);
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تسجيل الدخول')),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(label: Text('اسم المستخدم')),
          ),
          TextField(
            focusNode: _passwordFocusNode,
            obscureText: true,
            decoration: InputDecoration(label: Text('كلمة المرور')),
          ),
        ],
      ),
    );
  }
}
```

---

### مثال 3: مع Custom Error Handler

```dart
/// Custom handler للتعامل مع أخطاء الحماية
class SecurityServiceWithErrorHandling {
  static Future<void> safeHideContent() async {
    try {
      await SecurityService.instance.hideContent();
    } catch (e) {
      // إذا فشلت الحماية، قد تريد تسجيل الخطأ أو إخطار المستخدم
      print('فشل في تفعيل الحماية: $e');
      // يمكنك إرسال تقرير للـ analytics أو logging service
      // await AnalyticsService.logSecurityError(e);
    }
  }

  static Future<void> safeShowContent() async {
    try {
      await SecurityService.instance.showContent();
    } catch (e) {
      print('فشل في إظهار المحتوى: $e');
    }
  }
}
```

---

### مثال 4: دمج مع BLoC Pattern

```dart
/// BLoC للحماية الأمنية
class SecurityBloc extends Bloc<SecurityEvent, SecurityState> {
  SecurityBloc() : super(SecurityInitial()) {
    on<HideContentEvent>(_onHideContent);
    on<ShowContentEvent>(_onShowContent);
  }

  Future<void> _onHideContent(
    HideContentEvent event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      await SecurityService.instance.hideContent();
      emit(ContentHidden());
    } catch (e) {
      emit(SecurityError(message: 'فشل في إخفاء المحتوى'));
    }
  }

  Future<void> _onShowContent(
    ShowContentEvent event,
    Emitter<SecurityState> emit,
  ) async {
    try {
      await SecurityService.instance.showContent();
      emit(ContentShown());
    } catch (e) {
      emit(SecurityError(message: 'فشل في إظهار المحتوى'));
    }
  }
}

// الـ Events:
abstract class SecurityEvent {}

class HideContentEvent extends SecurityEvent {}

class ShowContentEvent extends SecurityEvent {}

// الـ States:
abstract class SecurityState {}

class SecurityInitial extends SecurityState {}

class ContentHidden extends SecurityState {}

class ContentShown extends SecurityState {}

class SecurityError extends SecurityState {
  final String message;
  SecurityError({required this.message});
}
```

---

### مثال 5: مع إشعارات الحالة

```dart
/// قطعة (Widget) تظهر حالة الحماية للمستخدم
class SecurityStatusIndicator extends StatefulWidget {
  @override
  _SecurityStatusIndicatorState createState() =>
      _SecurityStatusIndicatorState();
}

class _SecurityStatusIndicatorState extends State<SecurityStatusIndicator>
    with WidgetsBindingObserver {
  late AppLifecycleState _currentState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentState = AppLifecycleState.resumed;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _currentState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isProtected = _currentState == AppLifecycleState.paused ||
        _currentState == AppLifecycleState.inactive;

    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isProtected ? Colors.red : Colors.green,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isProtected ? Icons.lock : Icons.lock_open,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 8),
            Text(
              isProtected ? 'محمي' : 'مرئي',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

---

### مثال 6: استخدام في Transaction Pages

```dart
/// صفحة العمليات المالية مع حماية متقدمة
class TransactionPage extends StatefulWidget {
  final String transactionId;

  const TransactionPage({required this.transactionId});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  void initState() {
    super.initState();
    // تفعيل الحماية الفورية عند دخول صفحة المعاملات
    _initializeSecurity();
  }

  Future<void> _initializeSecurity() async {
    // حماية فورية
    await SecurityService.instance.hideContent();
    
    // يمكنك أيضاً فعّل قيود إضافية مثل:
    // - منع Screenshot من لوحة الإشعارات
    // - منع Print Screen
    // - منع Accessibility Services
  }

  Future<void> _confirmTransaction() async {
    // عند تأكيد العملية، أظهر رسالة نجاح ثم أخفِ المحتوى مرة أخرى
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تم بنجاح'),
        content: Text('تمت العملية بنجاح'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // أعد تفعيل الحماية
              SecurityService.instance.hideContent();
            },
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تأكيد العملية')),
      body: Center(
        child: ElevatedButton(
          onPressed: _confirmTransaction,
          child: Text('تأكيد'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // عند مغادرة الصفحة
    SecurityService.instance.showContent();
    super.dispose();
  }
}
```

---

### مثال 7: Customization في MainActivity

```kotlin
// إذا أردت تخصيص السلوك أكثر:

private fun hideContent() {
    try {
        // تفعيل FLAG_SECURE
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )

        // يمكنك أيضاً إضافة flags إضافية:
        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )

        Log.d(TAG, "تم تفعيل الحماية الكاملة")

        // إضافة overlay أسود
        if (overlayView == null) {
            overlayView = FrameLayout(this).apply {
                setBackgroundColor(android.graphics.Color.BLACK)
                // يمكنك أيضاً إضافة alpha للشفافية الجزئية
                // setAlpha(0.9f)
            }

            val params = WindowManager.LayoutParams().apply {
                type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_APPLICATION
                } else {
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_PHONE
                }
                format = PixelFormat.OPAQUE
                flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                        WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
                width = WindowManager.LayoutParams.MATCH_PARENT
                height = WindowManager.LayoutParams.MATCH_PARENT
            }

            windowManager.addView(overlayView, params)
        }
    } catch (e: Exception) {
        Log.e(TAG, "خطأ في hideContent: ${e.message}", e)
    }
}
```

---

### مثال 8: Logging و Analytics

```dart
/// Integration مع Analytics Service:
class SecurityServiceWithAnalytics {
  static Future<void> hideContent() async {
    try {
      await SecurityService.instance.hideContent();
      
      // Log للـ Analytics
      // await FirebaseAnalytics.instance.logEvent(
      //   name: 'security_hide_content',
      //   parameters: {
      //     'timestamp': DateTime.now().toIso8601String(),
      //     'device_id': await _getDeviceId(),
      //   },
      // );
      
    } catch (e) {
      // Log الخطأ للـ Analytics
      // await CrashlyticService.recordError(
      //   error: e,
      //   reason: 'Failed to hide content',
      // );
    }
  }
}
```

---

## 📖 ملاحظات استخدام متقدمة:

### ✅ الممارسات الجيدة:

```dart
// ✓ استخدم المراقب التلقائي
void main() async {
  await SecurityService.instance.initialize();  // ✓ صحيح
  runApp(MyApp());
}

// ✓ في الصفحات الحساسة:
@override
void initState() {
  super.initState();
  SecurityService.instance.hideContent();  // ✓ إضافي
}

// ✓ نظّف الموارد:
@override
void dispose() {
  SecurityService.instance.showContent();  // ✓ تنظيف
  super.dispose();
}
```

### ❌ تجنب:

```dart
// ❌ تكرار الاستدعاءات المتكررة
for (int i = 0; i < 100; i++) {
  SecurityService.instance.hideContent();  // ❌ لا تفعل هذا
}

// ❌ عدم التنظيف
@override
void initState() {
  super.initState();
  SecurityService.instance.hideContent();
  // ❌ لا تنسَ showContent() في dispose()
}
```

---

## 🔍 اختبار Advanced Features:

```bash
# اختبار مع إعادة التشغيل السريع (Hot Reload)
flutter run

# اختبار مع إعادة بناء كاملة (Hot Restart)
flutter run -c Release

# اختبار على أجهزة متعددة
flutter run -d <device_id>

# اختبار مع مراقبة الـ logs:
flutter run --verbose 2>&1 | grep -i security
```

---

## 📊 قياس الأداء:

```kotlin
// في MainActivity.kt، يمكنك قياس الأداء:
private fun hideContent() {
    val startTime = System.currentTimeMillis()
    
    try {
        // ... hideContent implementation
        
        val duration = System.currentTimeMillis() - startTime
        Log.d(TAG, "hideContent استغرق: ${duration}ms")
    } catch (e: Exception) {
        Log.e(TAG, "خطأ: ${e.message}", e)
    }
}
```

---

**هذه أمثلة متقدمة لتوسيع الاستخدام حسب احتياجات مشروعك!**
