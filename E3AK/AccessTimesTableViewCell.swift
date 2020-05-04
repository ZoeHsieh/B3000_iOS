//
//  AccessTimesTableViewCell.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/16.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit

class AccessTimesTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var accessTimesTextField: UITextField!
    var openTimes:Int = 0
    var openTimes_cmd:String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        accessTimesTextField.placeholder =  NSLocalizedString("Please enter access times", comment: "")
        
        accessTimesTextField.addTarget(self, action: #selector(AccessTimesTableViewCell.didEdit), for: .editingChanged)
        //        accessTimesTextField.addTarget(self, action: #selector(AccessTimesTableViewCell.didEdit), for: .editingDidEnd)
    }
    
    func setTimesValue(times:Int){
        
        
        if times > 255 {
            
            
            accessTimesTextField.text = String(format:"%d",times)
            accessTimesTextField.text = accessTimesTextField.text! + NSLocalizedString("(format error)", comment: "")
            accessTimesTextField.textColor = UIColor.red
            openTimes = times
        }else{
            accessTimesTextField.text = String(format:"%d",times)
            accessTimesTextField.textColor = UIColor.darkGray
            
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    @objc func didEdit(){
        
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٠", with: "0", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "١", with: "1", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٢", with: "2", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٣", with: "3", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٤", with: "4", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٥", with: "5", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٦", with: "6", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٧", with: "7", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٨", with: "8", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "٩", with: "9", options: .literal, range: nil)
        
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۰", with: "0", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۱", with: "1", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۲", with: "2", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۳", with: "3", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۴", with: "4", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۵", with: "5", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۶", with: "6", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۷", with: "7", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۸", with: "8", options: .literal, range: nil)
        accessTimesTextField.text = accessTimesTextField.text?.replacingOccurrences(of: "۹", with: "9", options: .literal, range: nil)
        
        if UserInfoTableViewController.isSettingAccess{
            
            if !(isPurnInt(string: accessTimesTextField.text!))
            {
                openTimes = 0
                openTimes_cmd = "0"
                accessTimesTextField.text = ""
                
            }else{
                
                openTimes = Int(accessTimesTextField.text!)!
                if openTimes >= 0 && openTimes <= 255
                {
                    openTimes_cmd = accessTimesTextField.text!
                }
                else if openTimes < 0
                {
                    openTimes = 0
                    openTimes_cmd = "0"
                    accessTimesTextField.text="0"
                }
                else if openTimes > 255  {
                    openTimes = 255
                    openTimes_cmd = "255"
                    accessTimesTextField.text="255"
                }
                
            }
            
            //            UserInfoTableViewController.tmpCMD[8] = 0x02
            //            UserInfoTableViewController.tmpCMD[23] = UInt8(accessTimesTextField.text!)!
            //            AccessTypesViewController.openTimes = Int(accessTimesTextField.text!)!
            
            
            
            UserInfoTableViewController.tmpCMD[8] = 0x02
            UserInfoTableViewController.tmpCMD[23] = UInt8(openTimes_cmd)!
        }
        
        
    }
    
    
    func checkLen(){
        if ( ( accessTimesTextField.text?.utf8.count)! > 3) {
            accessTimesTextField.deleteBackward();
            
        }
        
        
    }
    
    
    
    
    func isPurnInt(string: String) -> Bool {
        
        let scan: Scanner = Scanner(string: string)
        
        var val:Int = 0
        
        return scan.scanInt(&val) && scan.isAtEnd
        
    }
    
    
}

