import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// يمنع لوحات مفاتيح الطرف الثالث (custom keyboards) في كامل التطبيق ويفرض
  /// لوحة Apple الآمنة. هذه اللوحات قد ترفع ما يُكتب (مثل seed phrase أو كلمة المرور)
  /// إلى السحابة. الأسلوب البنكي القياسي على iOS هو المنع لا التحذير.
  override func application(
    _ application: UIApplication,
    shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier
  ) -> Bool {
    if extensionPointIdentifier == .keyboard {
      return false
    }
    return true
  }
}
