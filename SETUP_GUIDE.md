# دليل تثبيت وتفعيل حماية البيانات الحساسة

## المتطلبات:
- ✅ Flutter SDK 3.0+
- ✅ Android SDK (min API 21)
- ✅ Kotlin (مثبت تلقائياً مع Android SDK)
- ✅ Gradle 7.0+

## خطوات الإعداد:

### 1️⃣ التحقق من Package Name
تأكد من أن package name صحيح في ملفات:

**في `android/app/src/main/AndroidManifest.xml`:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.rdb">  <!-- تحقق من أن القيمة مطابقة -->
```

**في `android/app/build.gradle`:**
```gradle
android {
    namespace = "com.example.rdb"  // تحقق من هنا أيضاً
}
```

**في `lib/services/security_service.dart`:**
```dart
static const platform = MethodChannel('com.example.rdb/security');
// يجب أن تطابق package name
```

**في `android/app/src/main/kotlin/com/example/rdb/MainActivity.kt`:**
```kotlin
private const val CHANNEL = "com.example.rdb/security"
// يجب أن تطابق MethodChannel name من Dart
```

### 2️⃣ التحقق من الملفات المُضافة

#### Dart Files:
```
lib/
  ├── services/
  │   └── security_service.dart  ✅ NEW
  └── utils/
      └── security_test_widget.dart  ✅ NEW
```

#### Android Files:
```
android/
  └── app/
      └── src/
          └── main/
              ├── kotlin/
              │   └── com/example/rdb/
              │       └── MainActivity.kt  ✏️ MODIFIED
              └── AndroidManifest.xml  ✏️ CHECKED
```

#### Documentation:
```
├── SECURITY_IMPLEMENTATION.md  ✅ NEW
└── SETUP_GUIDE.md  ✅ NEW (هذا الملف)
```

### 3️⃣ بناء والتشغيل

#### Clean Build (موصى به):
```bash
# Flutter cleanup
flutter clean

# Gradle cleanup
cd android
./gradlew clean
cd ..

# Get dependencies
flutter pub get

# Build APK (Debug)
flutter build apk --debug

# أو Install على جهاز
flutter run
```

#### Fast Build (تطوير سريع):
```bash
flutter run
```

### 4️⃣ الاختبار

#### اختبار يدوي:
1. **تشغيل التطبيق على جهاز فعلي أو محاكي**
   ```bash
   flutter run
   ```

2. **اختبار السلوك الأساسي:**
   - افتح التطبيق
   - اضغط زر البيت → شاشة سوداء تظهر
   - ارجع للتطبيق → الشاشة السوداء تختفي
   - افتح Recent Apps → يجب أن ترى شاشة سوداء فقط

3. **اختبار من مختلف الحالات:**
   - اضغط زر البيت (Home)
   - افتح تطبيق آخر
   - استقبل مكالمة هاتفية
   - أغلق التطبيق

#### اختبار Screenshot:
```bash
# على Android (عبر ADB):
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# يجب أن يفشل الأمر عند تفعيل FLAG_SECURE
```

#### اختبار Logcat:
```bash
# مشاهدة logs من SecurityService:
adb logcat | grep "SecurityService"

# مثال على Output:
# SecurityService: تم تفعيل FLAG_SECURE
# SecurityService: تم إضافة overlay أسود
# SecurityService: تم إزالة FLAG_SECURE
# SecurityService: تم إزالة overlay أسود
```

### 5️⃣ استكشاف الأخطاء

#### مشكلة: Black Overlay لم يظهر
**الحل:**
```kotlin
// في MainActivity.kt، تأكد من أن type صحيح:
type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
    WindowManager.LayoutParams.TYPE_APPLICATION  // Android 8.0+
} else {
    WindowManager.LayoutParams.TYPE_PHONE  // أقدم من ذلك
}
```

#### مشكلة: MethodChannel error
**الحل:**
```
خطأ: "com.example.rdb/security not found"
↓
تحقق من:
1. Package name في جميع الملفات
2. CHANNEL constant في MainActivity.kt
3. MethodChannel name في Dart
```

#### مشكلة: تطبيق متوقف عند تشغيل
**الحل:**
```bash
# حذف build directories:
flutter clean
cd android && ./gradlew clean && cd ..

# إعادة البناء:
flutter pub get
flutter run
```

#### مشكلة: Permission denied
**الحل:**
```
لا نحتاج لصلاحيات إضافية لـ FLAG_SECURE و overlay من Activity
إذا حصلت على permission error:
1. تحقق من AndroidManifest.xml
2. تأكد أنك لا تستخدم TYPE_SYSTEM_ALERT أو TYPE_SYSTEM_OVERLAY
   (استخدم TYPE_APPLICATION بدلاً منه)
```

### 6️⃣ متغيرات التخصيص

#### تغيير الـ Channel Name:
إذا كنت تريد استخدام اسم مختلف للـ channel:

**في Dart (security_service.dart):**
```dart
static const platform = MethodChannel('com.yourcompany.yourapp/security');
```

**في Android (MainActivity.kt):**
```kotlin
private const val CHANNEL = "com.yourcompany.yourapp/security"
```

#### تغيير لون Overlay:
```kotlin
overlayView = FrameLayout(this).apply {
    // لون أسود
    setBackgroundColor(android.graphics.Color.BLACK)
    
    // أو لون مخصص:
    setBackgroundColor(0xFF1a1a1a)  // رمادي غامق جداً
}
```

#### تغيير Window Flags:
```kotlin
private fun hideContent() {
    window.setFlags(
        WindowManager.LayoutParams.FLAG_SECURE or
        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,  // مثال إضافي
        WindowManager.LayoutParams.FLAG_SECURE or
        WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
    )
}
```

### 7️⃣ Production Build

#### بناء Release APK:
```bash
flutter build apk --release
```

#### بناء App Bundle (للـ Google Play):
```bash
flutter build appbundle --release
```

#### التوقيع:
```bash
# تأكد من وجود signing configuration في build.gradle
# ثم بناء:
flutter build appbundle --release
```

### 8️⃣ Verification Checklist

قبل إرسال للـ Production:

- [ ] تم اختبار على جهاز فعلي (ليس محاكي فقط)
- [ ] Black Overlay يظهر عند الذهاب للخلفية
- [ ] الـ overlay يختفي عند العودة
- [ ] في Recent Apps، الشاشة سوداء
- [ ] لا توجد أخطاء في logcat
- [ ] لا توجد رسائل خطأ للمستخدم
- [ ] الأداء لم ينخفض بشكل ملحوظ
- [ ] FLAG_SECURE مفعّل (اختبر screenshot)

### 9️⃣ معلومات التصحيح

#### قراءة Logs كاملة:
```bash
adb logcat -v time | grep -E "(SecurityService|LifecycleObserver|MainActivity)"
```

#### قراءة Flutter Logs فقط:
```bash
flutter logs
```

#### إيقاف التطبيق والبدء من جديد:
```bash
adb shell am force-stop com.example.rdb
flutter run
```

---

## اتصل بالدعم إذا:
- كنت بحاجة لاستخدام package name مختلف
- أردت تفعيل features أمنية إضافية
- واجهت مشاكل في compatibility مع أجهزة محددة
