//
//  MasterFAQ.swift
//  E3AK
//
//  Created by twkazuya on 2017/11/6.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit


class MasterFAQ: BLE_ViewController,UIScrollViewDelegate {
    var mydelegate : PassDataDelegate!
    
    @IBOutlet weak var scrollview: UIScrollView!
    
    @IBOutlet weak var tit_admin_passcode: UILabel!
    @IBOutlet weak var dsc_admin_passcode: UILabel!
    @IBOutlet weak var tit_door_sensor: UILabel!
    @IBOutlet weak var dsc_door_sensor: UILabel!
    @IBOutlet weak var tit_tamper_alarm: UILabel!
    @IBOutlet weak var dsc_tamper_alarm: UILabel!
    @IBOutlet weak var tit_auto_proximity_range: UILabel!
    @IBOutlet weak var dsc_auto_proximity_range: UILabel!
    @IBOutlet weak var tit_device_time: UILabel!
    @IBOutlet weak var dsc_device_time: UILabel!
    @IBOutlet weak var tit_users: UILabel!
    @IBOutlet weak var dsc_users: UILabel!
    @IBOutlet weak var tit_audit_trail: UILabel!
    @IBOutlet weak var dsc_audit_trail: UILabel!
    @IBOutlet weak var tit_bakcup_data: UILabel!
    @IBOutlet weak var dsc_bakcup_data: UILabel!
    @IBOutlet weak var tit_restore_backup: UILabel!
    @IBOutlet weak var dsc_restore_backup: UILabel!
    @IBOutlet weak var tit_reset_procedures: UILabel!
    @IBOutlet weak var tit_reset_button: UILabel!
    @IBOutlet weak var dsc_reset_button: UILabel!
    @IBOutlet weak var tit_reset_pins: UILabel!
    @IBOutlet weak var dsc_reset_pins: UILabel!
    
    @IBOutlet weak var ds: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = GetSimpleLocalizedString("tooltip_FAQ")
        
        tit_admin_passcode.text = GetSimpleLocalizedString("settings_Admin_pwd")
        dsc_admin_passcode.text = GetSimpleLocalizedString("tooltip_dsc_admin_passcode")
        
        tit_door_sensor.text = GetSimpleLocalizedString("Door Sensor")
        dsc_door_sensor.text = GetSimpleLocalizedString("tooltip_dsc_door_sensor")
        
        tit_tamper_alarm.text = GetSimpleLocalizedString("Tamper Sensor")
        dsc_tamper_alarm.text = GetSimpleLocalizedString("tooltip_dsc_tamper_alarm")
        
        tit_auto_proximity_range.text = GetSimpleLocalizedString("Proximity Read Range")
        dsc_auto_proximity_range.text = GetSimpleLocalizedString("tooltip_dsc_proximity_read_range")
        
        tit_device_time.text = GetSimpleLocalizedString("Device Time")
        dsc_device_time.text = GetSimpleLocalizedString("tooltip_dsc_device_time")
        
        tit_users.text = GetSimpleLocalizedString("Users")
        dsc_users.text = GetSimpleLocalizedString("tooltip_dsc_users")
        
        tit_audit_trail.text = GetSimpleLocalizedString("Activity History")
        dsc_audit_trail.text = GetSimpleLocalizedString("tooltip_dsc_history")
        
        tit_bakcup_data.text = GetSimpleLocalizedString("Backup")
        dsc_bakcup_data.text = GetSimpleLocalizedString("tooltip_dsc_backup")
        
        tit_restore_backup.text = GetSimpleLocalizedString("Restore")
        dsc_restore_backup.text = GetSimpleLocalizedString("tooltip_dsc_restore")
        
        tit_reset_procedures.text = GetSimpleLocalizedString("tooltip_dsc_reset_title")
        tit_reset_button.text = GetSimpleLocalizedString("tooltip_dsc_reset_button_title")
        dsc_reset_button.text = GetSimpleLocalizedString("tooltup_dsc_reset_button_detail")
        
        tit_reset_pins.text = GetSimpleLocalizedString("tooltip_dsc_reset_pins_title")
        dsc_reset_pins.text = GetSimpleLocalizedString("tooltup_dsc_reset_pins_detail")
        
        
        
        let userLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
        if let userLanguage = userLanguages.first
        {
            print(userLanguage)
            let startIndex = userLanguage.index(userLanguage.startIndex, offsetBy: 0)
            let endIndex = userLanguage.index(userLanguage.startIndex, offsetBy: 1)
            let subStr = userLanguage[startIndex...endIndex]
            
            if (subStr == "es")
            {
                ds.image = UIImage(named: "ds_spanish")
            }
            else
            {
                ds.image = UIImage(named: "ds")
            }
        }
        
        
        
        scrollview.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.mydelegate.setcurrentdate()
    }
    
    
    
    
}

