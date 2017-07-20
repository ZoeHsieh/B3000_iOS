//
//  AboutUsViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/21.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var appversionButton: UIButton!
    
    @IBOutlet weak var DeviceModelTitle: UILabel!
    
    @IBOutlet weak var DeviceModelValue: UILabel!
    
    var deviceModel:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = GetSimpleLocalizedString("About Us")
        DeviceModelTitle.text = GetSimpleLocalizedString("Device Model")
        DeviceModelValue.text = "E3AK"//deviceModel
        appversionButton.setTitle(GetSimpleLocalizedString("APP version") + Config.APPversion, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
