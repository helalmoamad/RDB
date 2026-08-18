plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.util.Properties

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

android {
    namespace = "com.rdb.www"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.rdb.www"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // يقرأ أولاً من متغيرات سيرفر GitHub، وإذا لم يجدها يقرأ من ملف key.properties المحلي
            keyAlias = System.getenv("ANDROID_KEY_ALIAS") ?: (keystoreProperties["keyAlias"] as? String) ?: ""
            keyPassword = System.getenv("ANDROID_KEY_PASSWORD") ?: (keystoreProperties["keyPassword"] as? String) ?: ""
            storePassword = System.getenv("ANDROID_KEYSTORE_PASSWORD") ?: (keystoreProperties["storePassword"] as? String) ?: ""
            
            val keystorePath = System.getenv("ANDROID_KEYSTORE_PATH")
            if (!keystorePath.isNullOrEmpty()) {
                // إذا كنا على سيرفر GitHub، الملف سيكون في مسار android/app
                storeFile = file(keystorePath)
            } else if (keystorePropertiesFile.exists()) {
                // إذا كنا محلياً على جهازك
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

// إعدادات Kotlin امتداد على مستوى المشروع، لا داخل android {} — كان الاستدعاء
// السابق ينجح فقط لأن Kotlin DSL يصل للمستقبل الخارجي، وهذا يُحذف مع AGP 9.
kotlin {
    jvmToolchain(17)
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Android 12+ Splash Screen API (backport for older versions).
    // Fixes white-screen / splash hang on Android 12/13 devices (e.g. Infinix).
    implementation("androidx.core:core-splashscreen:1.0.1")
}