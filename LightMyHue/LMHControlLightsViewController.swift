//
//  LMHControlLightsViewController.swift
//  LightMyHue
//
//  Ported from https://github.com/PhilipsHue/PhilipsHueSDK-iOS-OSX/blob/master/QuickStartApp_iOS/HueQuickStartApp-iOS/PHControlLightsViewController.m
//  and https://github.com/kevindew/Hue-Quick-Start-iOS-Swift/blob/master/Hue%20Quick%20Start%20iOS%20Swift/ControlLightsViewController.swift
//
//  Created by Matthijs van der Linden on 18/05/16.
//  Copyright © 2016 Matthijs van der Linden. All rights reserved.
//

import UIKit

class LMHControlLightsViewController: UIViewController {
  
  let maxHue = 65535
  
  @IBOutlet var bridgeMacLabel: UILabel?
  @IBOutlet var bridgeIpLabel: UILabel?
  @IBOutlet var bridgeLastHeartbeatLabel: UILabel?
  @IBOutlet var randomLightsButton: UIButton?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let notificationManager = PHNotificationManager.defaultManager()
    // Register for the local heartbeat notifications
    notificationManager.registerObject(self, withSelector: #selector(LMHControlLightsViewController.localConnection), forNotification: LOCAL_CONNECTION_NOTIFICATION)
    
    notificationManager.registerObject(self, withSelector: #selector(LMHControlLightsViewController.noLocalConnection), forNotification: NO_LOCAL_CONNECTION_NOTIFICATION)
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Find Bridge", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(LMHControlLightsViewController.findNewBridgeButtonAction))
    
    navigationItem.title = "QuickStart"
    
    noLocalConnection()
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @nonobjc func edgesForExtendedLayout() -> UIRectEdge {
    return [UIRectEdge.Left, UIRectEdge.Bottom, UIRectEdge.Right]
  }
  
  
  func localConnection() {
    loadConnectedBridgeValues()
  }
  
  
  func noLocalConnection() {
    bridgeLastHeartbeatLabel?.text = "Not connected"
    bridgeLastHeartbeatLabel?.enabled = false
    bridgeIpLabel?.text = "Not connected"
    bridgeIpLabel?.enabled = false
    bridgeMacLabel?.text = "Not connected"
    bridgeMacLabel?.enabled = false
    
    randomLightsButton?.enabled = false
  }
  
  
  func loadConnectedBridgeValues() {
    let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
    
    // Check if we have connected to a bridge before
    if cache?.bridgeConfiguration?.ipaddress != nil {
      // Set the ip address of the bridge
      bridgeIpLabel?.text = cache!.bridgeConfiguration!.ipaddress
      
      // Set the mac adress of the bridge
      bridgeMacLabel?.text = cache!.bridgeConfiguration!.mac
      
      
      // Check if we are connected to the bridge right now
      let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
      if appDelegate.phHueSdk.localConnected() {
        
        // Show current time as last successful heartbeat time when we are connected to a bridge
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = .MediumStyle
        bridgeLastHeartbeatLabel?.text = dateFormatter.stringFromDate(NSDate())
        
        randomLightsButton?.enabled = true
      } else {
        bridgeLastHeartbeatLabel?.text = "Waiting..."
        randomLightsButton?.enabled = false
      }
    }
  }
  
  
  //  @IBAction func randomizeColoursOfConnectLights(AnyObject) {
  @IBAction func randomizeColoursOfConnectLights(_: AnyObject) {
    
    randomLightsButton?.enabled = false
    let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
    let bridgeSendAPI = PHBridgeSendAPI()
    
    for light in cache!.lights!.values {
      // don't update state of non-reachable lights
      if light.lightState!.reachable == 0 {
        continue
      }
      
      let lightState = PHLightState()
      
      if light.type == DIM_LIGHT {
        // Lux bulbs just get a random brightness
        lightState.brightness = Int(arc4random()) % 254
      } else {
        let hueColor = Int(arc4random_uniform(UInt32(maxHue)))

        lightState.hue = hueColor//Int(Int(arc4random()) % 10000)
        lightState.brightness = 254
        lightState.saturation = 254
      }
      
      // Send lightstate to light
      bridgeSendAPI.updateLightStateForId(light.identifier, withLightState: lightState, completionHandler: { (errors: [AnyObject]!) -> () in
        
        if errors != nil {
          let message = String(format: NSLocalizedString("Errors %@", comment: ""), errors)
          NSLog("Response: \(message)")
        }
        self.randomLightsButton?.enabled = true
      })
    }
  }
  
  
  @IBAction func lightsOnBtn(sender: UIButton) {
    
    let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
    let bridgeSendAPI = PHBridgeSendAPI()
    
    for light in cache!.lights!.values {
      // don't update state of non-reachable lights
      if light.lightState!.reachable == 0 {
        continue
      }
      
      let lightState = PHLightState()

      lightState.brightness = 254
      lightState.saturation = 254
      lightState.on = true
 
      // Send lightstate to light
      bridgeSendAPI.updateLightStateForId(light.identifier, withLightState: lightState, completionHandler: { (errors: [AnyObject]!) -> () in
        
        if errors != nil {
          let message = String(format: NSLocalizedString("Errors %@", comment: ""), errors)
          NSLog("Response: \(message)")
        }
        self.randomLightsButton?.enabled = true
      })
    }
  }
  
  
  @IBAction func lightsOffBtn(sender: UIButton) {
    
    let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
    let bridgeSendAPI = PHBridgeSendAPI()
    
    for light in cache!.lights!.values {
      // don't update state of non-reachable lights
      if light.lightState!.reachable == 0 {
        continue
      }
      
      let lightState = PHLightState()
      
      lightState.on = false
      
      // Send lightstate to light
      bridgeSendAPI.updateLightStateForId(light.identifier, withLightState: lightState, completionHandler: { (errors: [AnyObject]!) -> () in
        
        if errors != nil {
          let message = String(format: NSLocalizedString("Errors %@", comment: ""), errors)
          NSLog("Response: \(message)")
        }
        self.randomLightsButton?.enabled = true
      })
    }
  }
  
  
  func findNewBridgeButtonAction() {
    let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    appDelegate.searchForBridgeLocal()
  }
}
