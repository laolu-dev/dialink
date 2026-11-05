import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Flutter doesn't expose Reduce Transparency; the glass theme asks here.
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DialinkAccessibility") {
      let channel = FlutterMethodChannel(
        name: "dialink/accessibility", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "reduceTransparency":
          result(UIAccessibility.isReduceTransparencyEnabled)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // The app icon follows the theme. nil is the primary icon (Glass).
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DialinkAppIcon") {
      let channel = FlutterMethodChannel(
        name: "dialink/app_icon", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        guard call.method == "setIcon" else {
          result(FlutterMethodNotImplemented)
          return
        }
        let app = UIApplication.shared
        // The theme, e.g. "Sage", or nil for the primary icon. Each flavour
        // has its own icon sets: AppIcon-Sage, or AppIconDev-Sage in dev.
        let prefix = Bundle.main.object(forInfoDictionaryKey: "DialinkIconPrefix") as? String ?? "AppIcon"
        let name = (call.arguments as? String).map { "\(prefix)-\($0)" }
        // Changing the icon shows a system alert, so skip it when unchanged.
        guard app.supportsAlternateIcons, app.alternateIconName != name else {
          result(false)
          return
        }
        app.setAlternateIconName(name) { error in
          if let error {
            result(FlutterError(code: "icon", message: error.localizedDescription, details: nil))
          } else {
            result(true)
          }
        }
      }
    }
  }
}
