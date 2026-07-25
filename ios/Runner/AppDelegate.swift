import Flutter
import UIKit
import Vision
import VisionKit

@main
@objc class AppDelegate: FlutterAppDelegate, VNDocumentCameraViewControllerDelegate {
  private let storageChannelName = "planora/storage"
  private let receiptScannerChannelName = "planora/receipt_scanner"
  private var didSetupChannels = false
  private var setupAttempts = 0
  private var receiptScanResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let result = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )

    scheduleChannelSetup()
    return result
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    scheduleChannelSetup()
  }

  private func scheduleChannelSetup() {
    guard !didSetupChannels else { return }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
      self?.setupChannelsIfPossible()
    }
  }

  private func setupChannelsIfPossible() {
    guard !didSetupChannels else { return }

    guard let controller = findFlutterViewController() else {
      setupAttempts += 1
      if setupAttempts < 20 { scheduleChannelSetup() }
      return
    }

    didSetupChannels = true
    setupStorageChannel(binaryMessenger: controller.binaryMessenger)
    setupReceiptScannerChannel(binaryMessenger: controller.binaryMessenger)
  }

  private func setupStorageChannel(binaryMessenger: FlutterBinaryMessenger) {
    let storageChannel = FlutterMethodChannel(
      name: storageChannelName,
      binaryMessenger: binaryMessenger
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
        result(UserDefaults.standard.string(forKey: key))

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
  }

  private func setupReceiptScannerChannel(binaryMessenger: FlutterBinaryMessenger) {
    let scannerChannel = FlutterMethodChannel(
      name: receiptScannerChannelName,
      binaryMessenger: binaryMessenger
    )

    scannerChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "scanReceipt" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.presentReceiptScanner(result: result)
    }
  }

  private func presentReceiptScanner(result: @escaping FlutterResult) {
    guard receiptScanResult == nil else {
      result(FlutterError(
        code: "SCAN_IN_PROGRESS",
        message: "A receipt scan is already in progress.",
        details: nil
      ))
      return
    }

    guard VNDocumentCameraViewController.isSupported else {
      result(FlutterError(
        code: "NOT_SUPPORTED",
        message: "Document scanning is not supported on this device.",
        details: nil
      ))
      return
    }

    guard let presenter = topViewController() else {
      result(FlutterError(
        code: "NO_VIEW_CONTROLLER",
        message: "Unable to present the receipt scanner.",
        details: nil
      ))
      return
    }

    receiptScanResult = result
    let scanner = VNDocumentCameraViewController()
    scanner.delegate = self
    presenter.present(scanner, animated: true)
  }

  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    controller.dismiss(animated: true) { [weak self] in
      self?.receiptScanResult?(FlutterError(
        code: "CANCELLED",
        message: "Receipt scanning was cancelled.",
        details: nil
      ))
      self?.receiptScanResult = nil
    }
  }

  func documentCameraViewController(
    _ controller: VNDocumentCameraViewController,
    didFailWithError error: Error
  ) {
    controller.dismiss(animated: true) { [weak self] in
      self?.receiptScanResult?(FlutterError(
        code: "SCAN_FAILED",
        message: error.localizedDescription,
        details: nil
      ))
      self?.receiptScanResult = nil
    }
  }

  func documentCameraViewController(
    _ controller: VNDocumentCameraViewController,
    didFinishWith scan: VNDocumentCameraScan
  ) {
    let images = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }
    controller.dismiss(animated: true) { [weak self] in
      self?.recognizeText(in: images)
    }
  }

  private func recognizeText(in images: [UIImage]) {
    guard !images.isEmpty else {
      receiptScanResult?(FlutterError(
        code: "EMPTY_SCAN",
        message: "No receipt pages were captured.",
        details: nil
      ))
      receiptScanResult = nil
      return
    }

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      var pageTexts: [String] = []
      var recognitionError: Error?

      for image in images {
        guard let cgImage = image.cgImage else { continue }
        var recognizedText = ""

        let request = VNRecognizeTextRequest { request, error in
          if let error = error {
            recognitionError = recognitionError ?? error
            return
          }

          let observations = request.results as? [VNRecognizedTextObservation] ?? []
          recognizedText = observations
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["vi-VN", "tr-TR", "en-US", "ru-RU"]

        do {
          try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
          if !recognizedText.isEmpty { pageTexts.append(recognizedText) }
        } catch {
          recognitionError = recognitionError ?? error
        }
      }

      let text = pageTexts.joined(separator: "\n")
      DispatchQueue.main.async {
        guard let self = self else { return }
        if text.isEmpty, let error = recognitionError {
          self.receiptScanResult?(FlutterError(
            code: "OCR_FAILED",
            message: error.localizedDescription,
            details: nil
          ))
        } else {
          self.receiptScanResult?([
            "text": text,
            "pageCount": images.count
          ])
        }
        self.receiptScanResult = nil
      }
    }
  }

  private func topViewController() -> UIViewController? {
    var controller: UIViewController? = findFlutterViewController()
    while let presented = controller?.presentedViewController {
      controller = presented
    }
    if let navigation = controller as? UINavigationController {
      return navigation.visibleViewController
    }
    if let tab = controller as? UITabBarController {
      return tab.selectedViewController
    }
    return controller
  }

  private func findFlutterViewController() -> FlutterViewController? {
    if let controller = window?.rootViewController as? FlutterViewController {
      return controller
    }

    for scene in UIApplication.shared.connectedScenes {
      guard let windowScene = scene as? UIWindowScene else { continue }
      for window in windowScene.windows {
        if let controller = window.rootViewController as? FlutterViewController {
          return controller
        }
        if let navigation = window.rootViewController as? UINavigationController,
           let controller = navigation.viewControllers.first as? FlutterViewController {
          return controller
        }
        if let tab = window.rootViewController as? UITabBarController,
           let controller = tab.selectedViewController as? FlutterViewController {
          return controller
        }
      }
    }
    return nil
  }
}
