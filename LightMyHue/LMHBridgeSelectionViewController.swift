//
//  LMHBridgeSelectionViewController.swift
//  LightMyHue
//
//  Ported from: https://github.com/PhilipsHue/PhilipsHueSDK-iOS-OSX/blob/master/QuickStartApp_iOS/SDKWizard/PHBridgeSelectionViewController.m
//  and https://github.com/kevindew/Hue-Quick-Start-iOS-Swift/blob/master/Hue%20Quick%20Start%20iOS%20Swift/BridgeSelectionViewController.swift
//
//  Created by Matthijs van der Linden on 18/05/16.
//  Copyright © 2016 Matthijs van der Linden. All rights reserved.
//

import UIKit

protocol PHBridgeSelectionViewControllerDelegate {
  func bridgeSelectedWithIpAddress(ipAddress: String, bridgeId: String)
}


class LMHBridgeSelectionViewController: UITableViewController {

  var bridgesFound: [String: String]?
  var delegate: PHBridgeSelectionViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set title of screen
    title = "Available Smart Bridges"
    
    let refreshBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh,
                                               target: self, action: #selector(LMHBridgeSelectionViewController.refreshButtonClicked(_:)))
    navigationItem.rightBarButtonItem = refreshBarButtonItem
  }
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func refreshButtonClicked(sender: UIBarButtonItem) {
    navigationController?.dismissViewControllerAnimated(true, completion: nil)
    (UIApplication.sharedApplication().delegate as! AppDelegate).searchForBridgeLocal()
  }
  
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return bridgesFound!.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    
    // Sort bridges by mac address
    let keys = [String](bridgesFound!.keys)
    let sortedKeys = keys.sort() { $0.caseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
    
    let mac = sortedKeys[indexPath.row]
    let ip = bridgesFound![mac]
    
    cell.textLabel?.text = mac
    cell.detailTextLabel?.text = ip
    
    return cell
  }
  
  
  override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return "Please select a SmartBridge to use for this application"
  }
  
  
  // MARK: - Table View Delegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // Sort bridges by mac address
    let keys = [String](bridgesFound!.keys)
    let sortedKeys = keys.sort() { $0.caseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
    
    // The choice of bridge to use is made, store the mac and ip address for this bridge
    
    // Get mac address and ip address of selected bridge
    let bridgeId = sortedKeys[indexPath.row]
    let ip = bridgesFound![bridgeId]!
    
    // Inform delegate
    delegate!.bridgeSelectedWithIpAddress(ip, bridgeId: bridgeId)
  }
}
