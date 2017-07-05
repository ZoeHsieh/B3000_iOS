//
//  UIViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/7.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework
import CoreBluetooth

extension UIViewController: StoryboardIdentifiable{
    /*
    // MARK: - CBCentralManagerDelegate
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
           }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
       
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
       
    }
    
    // MARK: - CBPeripheralDelegate
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            print("Error discovering services: \(error?.localizedDescription)")
            
            dismiss(animated: true, completion: nil)
            return
        }
        
        if let services = peripheral.services {
            
            for service in services {
                
                print("Discovered service: \(service)")
                if service.uuid == CBUUID(string:Config.serviceUUID){
                    delayOnMainQueue(delay: 0.1, closure: {
                        peripheral.discoverCharacteristics([CBUUID(string:Config.charUUID)], for: service)
                        
                    })
                }
            }
        }

    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("Discover Characteristics!!!")
        let characteristic = service.characteristics?[0]
        bpChar = characteristic
        peripheral.setNotifyValue(true, for: characteristic!)
        
        
        

        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
       
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else{
            print("ERROR on reading value of \(characteristic.uuid): \(error?.localizedDescription)")
            return
        }
        
        if (characteristic.value != nil) {
            var rawData = characteristic.value
            /*for j in 0 ... (rawData?.count)! - 1 {
             
             print(String(format:"r[%d]=%02X",j,(rawData?[j])!))
             }*/
            
            
            tmpBuff = tmpBuff + rawData!
            /*for i in 0 ... (tmpBuff.count) - 1 {
             print(String(format:"total_tmp=%02X",(tmpBuff[i])))
             }*/
            if (tmpBuff.count) > 5{
                var count = 0
                var start_index = 0
                var end_index = 0
                var parseflag = false
                var cmdLen :Int = 0
                for i in 0 ... (tmpBuff.count) - 1{
                    if tmpBuff[i] == BPprotocol.packetHead_Tail{
                        count += 1
                        if count == 1{
                            start_index = i
                            cmdLen = Int((UInt16(tmpBuff[start_index+3])<<8 | UInt16(tmpBuff[start_index+4])&0x00FF)) + 4
                        }else if count == 2{
                            end_index = i
                            if (start_index < end_index) && (end_index - start_index - 1 == cmdLen){
                                parseflag = true
                                break
                            }else{
                                count -= 1
                            }
                        }
                    }
                }
                
                if parseflag{
                    
                    
                    var cmd = [UInt8]()
                    for i in start_index+1 ... end_index-1 {
                        cmd.append((tmpBuff[i]))
                    }
                    
                    cmdAnalysis(cmd: cmd)
                    
                    parseflag = false
                    let tmp = tmpBuff
                    tmpBuff.removeAll()
                    // print("end =%d \(end_index)")
                    //print("tmp count =%d \(tmp.count - 1)")
                    if end_index != tmp.count - 1 {
                        for j in end_index ... (tmp.count) - 1
                        {
                            tmpBuff.append(tmp[j])
                            
                        }
                        for i in 0 ... (tmpBuff.count) - 1 {
                            print(String(format:"tmp=%02X",(tmpBuff[i])))
                        }
                    }
                    
                    
                }
                
            }
        }
        
    }*/
    

    public func openBlueTooth_Setting() {
        let url = URL(string: "APP-Prefs:root=Bluetooth") //for Bluetooth Setting
        let app = UIApplication.shared
        
        let alertController = UIAlertController(title: "Enable the BlueTooth?", message: "Do You Enable the BlueTooth ?", preferredStyle: .alert)
        
        let cancelAct = UIAlertAction(title: "cancel", style: UIAlertActionStyle.cancel, handler: nil)
        
        let openBtAct = UIAlertAction(title: "Open", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            app.openURL(url!)
        }
        
        alertController.addAction(cancelAct);
        alertController.addAction(openBtAct);
        
        self.present(alertController, animated: true, completion: nil)
        
        //app.openURL(url!)
    }

    func setNavigationBarItemWithImage(imageName: String) {
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: (UIImage(named: imageName)), style: .plain, target: self, action: #selector(self.didTapItem))
        rightBarButtonItem.tintColor = HexColor("00B900")
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func setNavigationBarRightItemWithTitle(title: String) {
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.didTapItem))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    func setNavigationBarSkipItem() {
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "略過", style: .plain, target: self, action: #selector(self.didTapSkipItem))
        rightBarButtonItem.tintColor = HexColor("00B900")
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    public func didTapItem() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    public func didTapSkipItem() {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
//        guard let rootViewController = window.rootViewController else {
//            return
//        }
        
        let storyboard = UIStoryboard(storyboard: .Main)
        let vc: HomeNavigationController = storyboard.instantiateViewController()
//        vc.view.frame = rootViewController.view.frame
//        vc.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        }, completion: { completed in
            // maybe do something here
        })
    }
    func Convert_RSSI_to_LEVEL(_ rssi: Int) -> Int {
        var value: Int = (Config.BLE_RSSI_MAX - rssi) / Config.BLE_RSSI_LEVEL_CONVERT_BASE
        
        if (value > Config.BLE_RSSI_LEVEL_MAX) {
            value = Config.BLE_RSSI_LEVEL_MAX;
        }
        
        if (value < Config.BLE_RSSI_LEVEL_MIN) {
            value = Config.BLE_RSSI_LEVEL_MIN;
        }
        
        return value
    }
    
    func Convert_LEVEL_to_RSSI(_ level: Int) -> Int {
        return (level * (-1) * (
            Config.BLE_RSSI_LEVEL_CONVERT_BASE)) + Config.BLE_RSSI_MAX;
    }
    
    func saveExpectLevelToDbByUUID(_ uuidString: String, _ expect_level: Int) {
        
      /*  //Save to DB
        storeInfo.setValue(expect_level, forKey: (uuidString + expectLevel_Value_Suffix))
        storeInfo.set(true, forKey: (uuidString + expectLevel_isUsed_Suffix))
        storeInfo.synchronize()*/
    }
    
    func readExpectLevelFromDbByUUID(_ uuidString: String) -> Int {
        
      /*  //Get Expect Level from DB
        var expect_level: Int? = storeInfo.integer(forKey: (uuidString + expectLevel_Value_Suffix))
        let isDeviceExist: Bool = storeInfo.bool(forKey: (uuidString + expectLevel_isUsed_Suffix))
        
        if(!isDeviceExist) {
            //print("expect_level is nil ")
            expect_level = BLE_RSSI_LEVEL_DEFAULT
        }
        
        //print("expect_level = \(expect_level)")*/
        
        return 0 //expect_level!
    }
    func delayOnMainQueue(delay: Double, closure: @escaping ()->()) {
        
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: closure)
    }
    
    func showToastDialog(title:String,message:String){
        
        
        let messageDailog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        delayOnMainQueue(delay: 1, closure: {
            messageDailog.dismiss(animated: true, completion: nil)
            
        })
        
        
        self.present(messageDailog, animated: true, completion: nil)
    }
    
    func GetSimpleLocalizedString(_ key: String) -> String {
        
        return NSLocalizedString(key, comment: "")
    }
    
    func backToMainPage(){
       
        delayOnMainQueue(delay: 0.5, closure: {
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        })
            }

    func alertWithTextField(title: String, subTitle: String, placeHolder: String, keyboard: UIKeyboardType, Tag:Int,handler: @escaping ((_ inputText: String?) -> Void)){
        
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = placeHolder
            textField.keyboardType = keyboard
            textField.tag = Tag;
            textField.addTarget(self, action: #selector(self.editAlertTextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        })
        
        
        let confirmAction = UIAlertAction(title:"confirm"/* GetSimpleLocalizedString("common_confirm")*/, style: .default, handler: { action in
            if let inputText = alertController.textFields!.first?.text{
                print("user input: \(inputText)")
                handler(inputText)
            }
        })
        let cancelAction = UIAlertAction(title:"cancel"/* GetSimpleLocalizedString("common_cancel")*/, style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
       
    func editAlertTextFieldDidChange(field: UITextField){
        let alertController: UIAlertController = self.presentedViewController as! UIAlertController
        let textField: UITextField = alertController.textFields![0];
        
        let addAction: UIAlertAction = alertController.actions[0];
        if textField.tag == 0{// for user id
            
            if ( (textField.text?.utf8.count)! > BPprotocol.userID_maxLen ) {
                textField.deleteBackward();
            }
            
            addAction.isEnabled = ((textField.text?.utf8.count)! >= 1 )
        }else if textField.tag == 1{ // for user pwd
            
            if ( (textField.text?.utf8.count)! > BPprotocol.userPD_maxLen ) {
                textField.deleteBackward();
            }
            addAction.isEnabled = ((textField.text?.characters.count)! >= 4 );
        }else if textField.tag == 2{ // for door delay time
            
            if ( (textField.text?.utf8.count)! > 4) {
                textField.deleteBackward();
            }
            if (textField.text?.utf8.count)! > 0{
                addAction.isEnabled = ((textField.text?.characters.count)! <= 4 ) && (Int16((textField.text!))! <= Config.DOOR_DELAY_TIME_LIMIT)
            }else{
                addAction.isEnabled = false
            }
        }else if textField.tag == 3{ // for access times
            
            if ( (textField.text?.utf8.count)! > 3) {
                textField.deleteBackward();
            }
            if (textField.text?.utf8.count)! > 0{
                addAction.isEnabled = ((textField.text?.characters.count)! <= 3 ) && (Int(textField.text!)!<=255)
            }else{
                addAction.isEnabled = false
            }
        }
        
        //Check Length
        
        
    }
    func loginAlert(title: String, subTitle: String, placeHolder1: String, placeHolder2: String, keyboard1: UIKeyboardType, keyboard2: UIKeyboardType, handler: @escaping ((_ inputText1: String?, _ inputText2: String?) -> Void)){
        
        
        let alertController = UIAlertController(title: title, message: subTitle, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = placeHolder1
            textField.keyboardType = keyboard1
            textField.tag = 0;
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        })
        /*alertController.addTextField(configurationHandler: { (textField) in
         textField.placeholder = "User Name"
         textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
         textField.isEnabled = false
         })*/
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = placeHolder2
            textField.keyboardType = keyboard2
            textField.tag = 1;
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        })
        
        let confirmAction = UIAlertAction(title:"confirm"/* GetSimpleLocalizedString("common_confirm")*/, style: .default, handler: { action in
            if let inputText1 = alertController.textFields!.first?.text, let inputText2 = alertController.textFields!.last?.text{
                print("user input: \(inputText1) & \(inputText2)")
                handler(inputText1, inputText2)
                
            }
        })
        
        let cancelAction = UIAlertAction(title: "cancel"/* GetSimpleLocalizedString("common_cancel")*/, style: .cancel, handler: nil)
        
        confirmAction.isEnabled = false
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    

    func alertTextFieldDidChange(field: UITextField){
        let alertController: UIAlertController = self.presentedViewController as! UIAlertController
        let textField_id: UITextField = alertController.textFields![0];
        let textField_password: UITextField = alertController.textFields![1];
        let addAction: UIAlertAction = alertController.actions[0];
        
        //Check Length
        if ( (textField_id.text?.utf8.count)! > BPprotocol.userID_maxLen ) {
            textField_id.deleteBackward();
        }
        
        if ( (textField_password.text?.utf8.count)! > BPprotocol.userPD_maxLen  ) {
            textField_password.deleteBackward();
        }
        
        addAction.isEnabled = ((textField_id.text?.characters.count)! >= 1 ) && ((textField_password.text?.characters.count)! >= 4 );
    }

   
}