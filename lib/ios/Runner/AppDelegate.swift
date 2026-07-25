import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let storageChannelName = "planora/storage"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let storageChannel = FlutterMethodChannel(
      name: storageChannelName,
      binaryMessenger: controller.binaryMessenger
    )

    storageChannel.setMethodCallHandler { call, result in
      guard let args = call.arguments as? [String: Any],
            let key = args["key"] as? String else {
        result(FlutterError(
          code: "INVALID_ARGUMENTS",
          message: "Missing storage key",
          details: nil
        ))
        return
      }

      switch call.method {
      case "getString":
        let value = UserDefaults.standard.string(forKey: key)
        result(value)

      case "setString":
        guard let value = args["value"] as? String else {
          result(FlutterError(
            code: "INVALID_ARGUMENTS",
            message: "Missing storage value",
            details: nil
          ))
          return
        }

        UserDefaults.standard.set(value, forKey: key)
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
