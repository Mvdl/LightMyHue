//
//  LMHBridgePushLinkViewController.swift
//  LightMyHue
//
//  Ported from: https://github.com/PhilipsHue/PhilipsHueSDK-iOS-OSX/blob/master/QuickStartApp_iOS/SDKWizard/PHBridgePushLinkViewController.m
//  and https://github.com/kevindew/Hue-Quick-Start-iOS-Swift/blob/master/Hue%20Quick%20Start%20iOS%20Swift/BridgePushLinkViewController.swift
//
//  Created by Matthijs van der Linden on 18/05/16.
//  Copyright © 2016 Matthijs van der Linden. All rights reserved.
//

import UIKit

protocol PHBridgePushLinkViewControllerDelegate {
  func pushlinkSuccess()
  func pushlinkFailed(_ error: PHError)
}


class LMHBridgePushLinkViewController: UIViewController {

  @IBOutlet var progressView: UIProgressView!
  var phHueSdk: PHHueSDK!
  var delegate: PHBridgePushLinkViewControllerDelegate!
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /// Starts the pushlinking process
  func startPushLinking() {
    
    // Set up the notifications for push linkng
    let notificationManager = PHNotificationManager.default()
    
    notificationManager?.register(self, with: #selector(self.authenticationSuccess), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION)
    
    notificationManager?.register(self, with: #selector(self.authenticationFailed), forNotification: PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION)
    
    notificationManager?.register(self, with: #selector(self.noLocalConnection), forNotification: PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION)
    
    notificationManager?.register(self, with: #selector(self.noLocalBridge), forNotification: PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION)
    
    notificationManager?.register(self, with: #selector(self.buttonNotPressed(_:)), forNotification: PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION)
    
    // Call to the hue SDK to start pushlinking process
    phHueSdk.startPushlinkAuthentication()
  }
  
  
  /// Notification receiver which is called when the pushlinking was successful
  func authenticationSuccess() {
    // The notification PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION was received. We have confirmed the bridge.
    
    // De-register for notifications and call pushLinkSuccess on the delegate
    PHNotificationManager.default().deregisterObject(forAllNotifications: self)
    
    // Inform delegate
    delegate.pushlinkSuccess()
  }
  
  
  /// Notification receiver which is called when the pushlinking failed because the time limit was reached
  func authenticationFailed() {
    // De-register for notifications and call pushLinkSuccess on the delegate
    PHNotificationManager.default().deregisterObject(forAllNotifications: self)
    
    let error = PHError(domain: SDK_ERROR_DOMAIN, code: Int(PUSHLINK_TIME_LIMIT_REACHED.rawValue), userInfo: [NSLocalizedDescriptionKey: "Authentication failed: time limit reached."])
    
    // Inform Delegate
    delegate.pushlinkFailed(error)
  }
  
  
  /// Notification receiver which is called when the pushlinking failed because the local connection to the bridge was lost
  func noLocalConnection() {
    // Deregister for all notifications
    PHNotificationManager.default().deregisterObject(forAllNotifications: self)
    
    let error = PHError(domain: SDK_ERROR_DOMAIN, code: Int(PUSHLINK_NO_CONNECTION.rawValue), userInfo: [NSLocalizedDescriptionKey: "Authentication failed: No local connection to bridge."])
    
    // Inform Delegate
    delegate.pushlinkFailed(error)
  }
  
  
  /// Notification receiver which is called when the pushlinking failed because we do not know the address of the local bridge
  func noLocalBridge() {
    // Deregister for all notifications
    PHNotificationManager.default().deregisterObject(forAllNotifications: self)
    
    let error = PHError(domain: SDK_ERROR_DOMAIN, code: Int(PUSHLINK_NO_LOCAL_BRIDGE.rawValue), userInfo: [NSLocalizedDescriptionKey: "Authentication failed: No local bridge found."])
    
    // Inform Delegate
    delegate.pushlinkFailed(error)
  }
  
  
  /// This method is called when the pushlinking is still ongoing but no button was pressed yet.
  /// :param: notification The notification which contains the pushlinking percentage which has passed.
  func buttonNotPressed(_ notification: Notification) {
    // Update status bar with percentage from notification
    let dict = notification.userInfo!
    let progressPercentage = dict["progressPercentage"] as! Int!
    
    // Convert percentage to the progressbar scale
    let progressBarValue = Float(progressPercentage!) / 100.0
    progressView.progress = progressBarValue
  }
}
