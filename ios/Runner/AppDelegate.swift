import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let storageChannelName = "planora/storage"
  private var didSetupStorageChannel = false
  private var setupAttempts = 0

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let result = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )

    scheduleStorageChannelSetup()

    return result
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    scheduleStorageChannelSetup()
  }

  private func scheduleStorageChannelSetup() {
    guard !didSetupStorageChannel else {
      return
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
      self?.setupStorageChannelIfPossible()
    }
  }

  private func setupStorageChannelIfPossible() {
    guard !didSetupStorageChannel else {
      return
    }

    guard let controller = findFlutterViewController() else {
      setupAttempts += 1

      if setupAttempts < 20 {
        scheduleStorageChannelSetup()
      }

      return
    }

    didSetupStorageChannel = true

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
        UserDefaults.standard.synchronize()
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func findFlutterViewController() -> FlutterViewController? {
    if let controller = window?.rootViewController as? FlutterViewController {
      return controller
    }

    for scene in UIApplication.shared.connectedScenes {
      guard let windowScene = scene as? UIWindowScene else {
        continue
      }

      for window in windowScene.windows {
        if let controller = window.rootViewController as? FlutterViewController {
          return controller
        }

        if let navigationController = window.rootViewController as? UINavigationController,
           let controller = navigationController.viewControllers.first as? FlutterViewController {
          return controller
        }

        if let tabBarController = window.rootViewController as? UITabBarController,
           let controller = tabBarController.selectedViewController as? FlutterViewController {
          return controller
        }
      }
    }

    return nil
  }
}
