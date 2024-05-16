import UIKit
import Flutter
import CloudKit

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
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func fetchCurrentUser(result: @escaping FlutterResult) {
      let container = CKContainer.default()
      container.fetchUserRecordID { (recordID, error) in
          if let userID = recordID, error == nil {
              result(userID.recordName)
          } else {
              result(FlutterError(code: "UNAVAILABLE",
                                  message: "无法获取iCloud用户ID",
                                  details: error?.localizedDescription))
          }
      }
  }
}
