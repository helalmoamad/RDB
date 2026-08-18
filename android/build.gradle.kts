allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// بعض الإضافات المحلولة تثبّت compileSdk قديماً في build.gradle الخاص بها بينما
// مكتبات AndroidX التي تعتمد عليها تشترط 34+، فيفشل checkDebugAarMetadata.
// المخالفون حالياً: firebase_messaging 14.7.10 · fluttertoast 8.2.14 ·
// image_cropper 9.1.0 (تبعية غير مباشرة). نرفع الأرضية لهم فقط بدل ترقية الحزم
// (ترقية firebase_messaging تجرّ firebase_core — طبقة ثانية، تُفصل في تذكرة).
// سطر logger.lifecycle ليس زينة: يثبت أن المعدَّل هو الوحدات المقصودة فقط.
//
// ⚠️ الترتيب إلزامي: evaluationDependsOn(":app") يُقيّم :app فوراً، وأي
// afterEvaluate يُسجَّل بعده يفشل بـ "project is already evaluated".
val compileSdkFloor = 34

subprojects {
    afterEvaluate {
        val androidExtension = extensions.findByName("android") ?: return@afterEvaluate
        androidExtension.withGroovyBuilder {
            val current = ("getCompileSdkVersion"() as? String)
                ?.substringAfter("android-")
                ?.toIntOrNull()
            if (current != null && current < compileSdkFloor) {
                logger.lifecycle(
                    "Raising ${project.name} compileSdk $current -> $compileSdkFloor",
                )
                "setCompileSdkVersion"(compileSdkFloor)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
