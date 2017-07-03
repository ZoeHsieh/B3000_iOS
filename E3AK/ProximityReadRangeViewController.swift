//
//  ProximityReadRangeViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/12.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit

class ProximityReadRangeViewController: UIViewController {

    @IBOutlet weak var deviceDistanceView: UIView!
    @IBOutlet weak var distanceSettingView: UIView!
    @IBOutlet weak var deviceSettingSliderValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "感應距離"
        deviceDistanceView.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        distanceSettingView.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        
    }
    
    @IBAction func deviceSettingSliderValueChanged(_ sender: UISlider) {
        
        let currentValue = Int(sender.value * 100 * 0.2)
        deviceSettingSliderValueLabel.text = "\(currentValue)"
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
