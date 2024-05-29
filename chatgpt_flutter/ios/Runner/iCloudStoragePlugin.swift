//
//  iCloudStoragePlugin.swift
//  Runner
//
//  Created by 褚红彪 on 5/29/24.
//

import Foundation
import Flutter
import UIKit

public class SwiftICloudStoragePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "iCloudStorage", binaryMessenger: registrar.messenger())
    let instance = SwiftICloudStoragePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "set" {
      if let arguments = call.arguments as? Dictionary<String, Any>,
         let key = arguments["key"] as? String,
         let value = arguments["value"] as? String {
        let iCloudKeyValueStore = NSUbiquitousKeyValueStore.default
        iCloudKeyValueStore.set(value, forKey: key)
        iCloudKeyValueStore.synchronize()
      }
      result(nil)
    } else if call.method == "get" {
      if let arguments = call.arguments as? Dictionary<String, Any>,
         let key = arguments["key"] as? String {
        let iCloudKeyValueStore = NSUbiquitousKeyValueStore.default
        let value = iCloudKeyValueStore.string(forKey: key)
        result(value)
      }
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}
