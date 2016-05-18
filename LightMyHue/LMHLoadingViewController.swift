//
//  LMHLoadingViewController.swift
//  LightMyHue
//
//  Ported from: https://github.com/kevindew/Hue-Quick-Start-iOS-Swift/blob/master/Hue%20Quick%20Start%20iOS%20Swift/LoadingViewController.swift
//
//  Created by Matthijs van der Linden on 18/05/16.
//  Copyright © 2016 Matthijs van der Linden. All rights reserved.
//

import UIKit

class LMHLoadingViewController: UIViewController {
  
    @IBOutlet var loadingLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
