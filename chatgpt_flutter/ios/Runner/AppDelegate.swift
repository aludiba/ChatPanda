import UIKit
import Flutter
import CloudKit
import AdSupport
import AppTrackingTransparency

private let channelName = "chatPanda/icloud"

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let iCloudChannel = FlutterMethodChannel(name: channelName,
                                             binaryMessenger: controller.binaryMessenger)
    iCloudChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getICloudUserID" {
        self?.fetchCurrentUser(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    GeneratedPluginRegistrant.register(with: self)
    self.requestIDFA()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func fetchCurrentUser(result: @escaping FlutterResult) {
      let container = CKContainer.default()
      container.fetchUserRecordID { (recordID, error) in
          if let userID = recordID, error == nil {
              print("ICloudUserID:\(userID),recordName:\(userID.recordName)")
              result(userID.recordName)
          } else {
              result(FlutterError(code: "UNAVAILABLE",
                                  message: "无法获取iCloud用户ID",
                                  details: error?.localizedDescription))
          }
      }
  }
    private func requestIDFA() {
      if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
          switch status {
          case .authorized:
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
              print("idfa:\(idfa)")
          case .denied, .restricted, .notDetermined:
              print("Tracking authorization denied or not determined")
          @unknown default:
              print("Unknown status")
          }
        }
      } else {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
          print("idfa1:\(idfa)")
      }
    }
}
