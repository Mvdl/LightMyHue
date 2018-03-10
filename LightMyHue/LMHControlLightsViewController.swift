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
  let maxDim = 254
  
  @IBOutlet var bridgeMacLabel: UILabel?
  @IBOutlet var bridgeIpLabel: UILabel?
  @IBOutlet var bridgeLastHeartbeatLabel: UILabel?
  @IBOutlet var randomLightsButton: UIButton?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let notificationManager = PHNotificationManager.default()
    // Register for the local heartbeat notifications
    notificationManager?.register(self, with: #selector(LMHControlLightsViewController.localConnection), forNotification: LOCAL_CONNECTION_NOTIFICATION)
    
    notificationManager?.register(self, with: #selector(LMHControlLightsViewController.noLocalConnection), forNotification: NO_LOCAL_CONNECTION_NOTIFICATION)
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Find Bridge", style: UIBarButtonItemStyle.plain, target: self, action: #selector(LMHControlLightsViewController.findNewBridgeButtonAction))
    
    navigationItem.title = "QuickStart"
    
    noLocalConnection()
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @nonobjc func edgesForExtendedLayout() -> UIRectEdge {
    return [UIRectEdge.left, UIRectEdge.bottom, UIRectEdge.right]
  }
  
  
  func localConnection() {
    loadConnectedBridgeValues()
  }
  
  
  func noLocalConnection() {
    bridgeLastHeartbeatLabel?.text = "Not connected"
    bridgeLastHeartbeatLabel?.isEnabled = false
    bridgeIpLabel?.text = "Not connected"
    bridgeIpLabel?.isEnabled = false
    bridgeMacLabel?.text = "Not connected"
    bridgeMacLabel?.isEnabled = false
    
    randomLightsButton?.isEnabled = false
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
      let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
      if appDelegate.phHueSdk.localConnected() {
        
        // Show current time as last successful heartbeat time when we are connected to a bridge
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium
        bridgeLastHeartbeatLabel?.text = dateFormatter.string(from: Date())
        
        randomLightsButton?.isEnabled = true
      } else {
        bridgeLastHeartbeatLabel?.text = "Waiting..."
        randomLightsButton?.isEnabled = false
      }
    }
  }
  
  
  //  @IBAction func randomizeColoursOfConnectLights(AnyObject) {
  @IBAction func randomizeColoursOfConnectLights(_: AnyObject) {
    
    randomLightsButton?.isEnabled = false
    let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
    let bridgeSendAPI = PHBridgeSendAPI()
    
    for light in cache!.lights!.values {
      // don't update state of non-reachable lights
      if (light as AnyObject).lightState!.reachable == 0 {
        continue
      }
      
      let lightState = PHLightState()
      
      if (light as AnyObject).type == DIM_LIGHT {
        // Lux bulbs just get a random brightness
        lightState.brightness = Int(arc4random_uniform(UInt32(maxDim))) as NSNumber
      } else {
        let hueColor = Int(arc4random_uniform(UInt32(maxHue)))

        lightState.hue = hueColor as NSNumber//Int(Int(arc4random()) % 10000)
        lightState.brightness = 254
        lightState.saturation = 254
      }
      
      // Send lightstate to light
      bridgeSendAPI.updateLightState(forId: (light as AnyObject).identifier, with: lightState, completionHandler: { (errors: [AnyObject]!) -> () in
        
        if errors != nil {
          let message = String(format: NSLocalizedString("Errors %@", comment: ""), errors)
          NSLog("Response: \(message)")
        }
        self.randomLightsButton?.isEnabled = true
      })
    }
  }
  
  
  @IBAction func lightsOnBtn(_ sender: UIButton) {
    
    let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
    let bridgeSendAPI = PHBridgeSendAPI()
    
    for light in cache!.lights!.values {
      // don't update state of non-reachable lights
      if (light as AnyObject).lightState!.reachable == 0 {
        continue
      }
      
      let lightState = PHLightState()

      lightState.brightness = 254
      lightState.saturation = 254
      lightState.on = true
 
      // Send lightstate to light
      bridgeSendAPI.updateLightState(forId: (light as AnyObject).identifier, with: lightState, completionHandler: { (errors: [AnyObject]!) -> () in
        
        if errors != nil {
          let message = String(format: NSLocalizedString("Errors %@", comment: ""), errors)
          NSLog("Response: \(message)")
        }
        self.randomLightsButton?.isEnabled = true
      })
    }
  }
  
  
  @IBAction func lightsOffBtn(_ sender: UIButton) {
    
    let cache = PHBridgeResourcesReader.readBridgeResourcesCache()
    let bridgeSendAPI = PHBridgeSendAPI()
    
    for light in cache!.lights!.values {
      // don't update state of non-reachable lights
      if (light as AnyObject).lightState!.reachable == 0 {
        continue
      }
      
      let lightState = PHLightState()
      
      lightState.on = false
      
      // Send lightstate to light
      bridgeSendAPI.updateLightState(forId: (light as AnyObject).identifier, with: lightState, completionHandler: { (errors: [AnyObject]!) -> () in
        
        if errors != nil {
          let message = String(format: NSLocalizedString("Errors %@", comment: ""), errors)
          NSLog("Response: \(message)")
        }
        self.randomLightsButton?.isEnabled = true
      })
    }
  }
  
  
  func findNewBridgeButtonAction() {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    appDelegate.searchForBridgeLocal()
  }
}
