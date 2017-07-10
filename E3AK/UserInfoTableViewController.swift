//
//  UserInfoTableViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/15.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit
import UIAlertController_Blocks
import CoreBluetooth

class UserInfoTableViewController: BLE_tableViewController {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    
   
   
   
    @IBOutlet weak var label_accessLimit: UILabel!
    @IBOutlet weak var keypadSwitch: UISwitch!
    
    var selectUser:Int = 0
    var userIndex :Int16 = 0
    var isKeypadCode:Bool = false
    static var tmpCMD = Data()
    static var isSettingAccess = false
    var limitType: UInt8!
    var startTimeArr: Array<Int>!
    var endTimeArr: Array<Int>!
    var openTimes: Int!
    var weekly: UInt8!
    
   // var newStartTimeArr = [Date().year, Date().month, Date().day, 0, 0, 0]
   // var newEndTimeArr = [Date().year + 1, Date().month, Date().day, 23, 50, 0]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        accountTextField.setTextFieldPaddingView()
        accountTextField.isUserInteractionEnabled = false
       // accountTextField.addTarget(self, action: #selector(UserInfoTableViewController.didTapID), for: .touchUpOutside)
        passwordTextField.setTextFieldPaddingView()
        passwordTextField.isUserInteractionEnabled = false
        //passwordTextField.addTarget(self, action: #selector(UserInfoTableViewController.didTapPWD), for: .editingDidBegin)
        keypadSwitch.isUserInteractionEnabled = false
        userIndex = Config.userListArr[selectUser]["index"] as! Int16
        passwordTextField.text = Config.userListArr[selectUser]["pw"] as! String
        accountTextField.text = Config.userListArr[selectUser]["name"] as! String
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        let cmd = Config.bpProtocol.getUserProperty(UserIndex: Int16(userIndex))
        Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
        

        
    }
    override func viewWillAppear(_ animated: Bool) {
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        if UserInfoTableViewController.isSettingAccess{
            let cmd = UserInfoTableViewController.tmpCMD
            print(String(format:"cmd cnt=%d", cmd.count))
                
            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
            UserInfoTableViewController.isSettingAccess = false
        }
        
    }

    @IBAction func didTapDelete(_ sender: Any) {
        UIAlertController.showAlert(
            in: self,
            withTitle: GetSimpleLocalizedString("確定要刪除？"),
            message: nil,
            cancelButtonTitle: GetSimpleLocalizedString("Cancel"),
            destructiveButtonTitle: nil,
            otherButtonTitles: [GetSimpleLocalizedString("OK")],
            tap: {(controller, action, buttonIndex) in
                if (buttonIndex == controller.cancelButtonIndex) {
                    print("Cancel Tapped")
                } else if (buttonIndex == controller.destructiveButtonIndex) {
                    print("Delete Tapped")
                } else if (buttonIndex >= controller.firstOtherButtonIndex) {
                    //print("Other Button Index \(buttonIndex - controller.firstOtherButtonIndex)")
                    //Config.userDeleted = self.id
                    let cmdData = Config.bpProtocol.setUserDel(UserIndex: self.userIndex)
                    Config.bleManager.writeData(cmd: cmdData,characteristic:self.bpChar!)
                    
                   
                }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section)
        {
        case 2:
            return 0;
        case 3:
            return 2;
        default:
            return 1;
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
        
                didTapID()
        }else if indexPath.section == 1{
            didTapPWD()
        }
        else if indexPath.section == 3 && indexPath.row == 0
        {
              var cmd = Data()
             if isKeypadCode
             {
               cmd = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: 0x00, LimitType: limitType, startTime:Util.toUInt8date(startTimeArr), endTime: Util.toUInt8date(endTimeArr), Times: UInt8(openTimes), weekly: weekly)
                Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
             }else{
                
                 cmd = Config.bpProtocol.setUserProperty(UserIndex: userIndex, Keypadunlock: 0x01, LimitType: limitType, startTime:Util.toUInt8date(startTimeArr), endTime: Util.toUInt8date(endTimeArr), Times: UInt8(openTimes), weekly: weekly)
                Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
                
            }
            UserInfoTableViewController.tmpCMD = cmd
            
        }

        else if indexPath.section == 3 && indexPath.row == 1
        {
            let vc = AccessTypesViewController(nib:R.nib.accessTypesViewController)
            AccessTypesViewController.startTimeArr = self.startTimeArr
            AccessTypesViewController.endTimeArr = self.endTimeArr
            AccessTypesViewController.openTimes = self.openTimes
            AccessTypesViewController.weekly = self.weekly
            vc.isKeypadCode = self.isKeypadCode
            if limitType == 0x00{
                vc.accessType = .Permanent
            }else if limitType == 0x03{
                vc.accessType = .Recurrent
            }else if limitType == 0x02{
                vc.accessType = .AccessTimes
            }else if limitType == 0x01{
                vc.accessType = .Schedule
            }
            vc.userIndex = self.userIndex
            vc.limitType = self.limitType
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func didTapID() {
        
        alertWithTextField(title: self.GetSimpleLocalizedString("settings_device_name_edit"), subTitle: "", placeHolder: accountTextField.text!, keyboard: .default ,Tag: 0,handler: { (inputText) in
            
            guard var newName: String = inputText else{
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("Wrong format!"))
                
                return
            }
            print(newName)
            
            if newName.utf8.count > 16{
                
                repeat{
                    var chars = newName.characters
                    chars.removeLast()
                    newName = String(chars)
                }while newName.utf8.count > 16
            }
           
            let nameArr = Config.userListArr.map{ $0["name"] as! String }
           
            print("name size = \(nameArr.count)")
            if nameArr.contains((newName)){
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_name"))
                return
            }
            
            if self.accountTextField?.text == Config.AdminID || self.accountTextField?.text == "ADMIN"{
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_name"))
                return
            }
            

            let nameUint8 = Util.StringtoUINT8(data: newName, len: 16, fillData: BPprotocol.nullData)
            
                       
            let cmd = Config.bpProtocol.setUserID(UserIndex: Int16(self.userIndex), ID: nameUint8)
            
            Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
             UserInfoTableViewController.tmpCMD = cmd
        })

    }
    
    func didTapPWD() {
        alertWithTextField(title: self.GetSimpleLocalizedString("settings_Admin_pwd_Edit"), subTitle: "", placeHolder: passwordTextField.text!, keyboard: .numberPad, Tag: 1, handler: { (inputText) in
            guard let newPWD: String = inputText else{
                
                //self.showAlert(message: "Wrong format!")
                return
            }
            if !((inputText?.isEmpty)!){
                guard (inputText?.characters.count)! > 3 && (inputText?.characters.count)! < BPprotocol.userPD_maxLen+1 else{
                    
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_pwd"))
                    return
                }
                
                let pwArr = Config.userListArr.map{ $0["pw"] as! String }
                
                
                if pwArr.contains(inputText!){
                    
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_password"))
                    return
                }
                
                
                let pwdUint8 = Util.StringtoUINT8(data: newPWD, len: BPprotocol.userPD_maxLen, fillData: BPprotocol.nullData)
                
                
                
                let cmd = Config.bpProtocol.setUserPWD(UserIndex: self.userIndex, Password: pwdUint8)
                Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
                
                UserInfoTableViewController.tmpCMD = cmd
                
                for j in 0 ... cmd.count - 1{
                    
                    print(String(format:"%02x ",cmd[j]))
                }
                
            }else{
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("wrong format!"))
            } })
       
    
    }


    override func cmdAnalysis(cmd:[UInt8]){
        
        
        let datalen = Int16( UInt16(cmd[2]) << 8 | UInt16(cmd[3] & 0x00FF))
        
        if datalen == Int16(cmd.count - 4) {
            
            switch cmd[0] {
                
            case BPprotocol.cmd_set_user_id:
                
                if cmd[4] == BPprotocol.result_success{
                    print("count =%d \(UserInfoTableViewController.tmpCMD.count)")
                    let cmdData = Array(UserInfoTableViewController.tmpCMD[7...UserInfoTableViewController.tmpCMD.count-1])
                    var userIDArray = [UInt8]()
                    for j in 0 ... BPprotocol.userID_maxLen - 1{
                        print(String(format:"%02x",cmdData[j]))
                        
                        if cmdData[j] != 0xFF && cmdData[j] != 0x00{
                            userIDArray.append(cmdData[j])
                        }
                    }
                    let userId = String(bytes: userIDArray, encoding: .utf8) ?? "No Name"
                    
                    Config.userListArr[selectUser]["name"] = userId
                    
                    accountTextField.text = userId
                    
                    
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_success"))
                }else{
                    UserInfoTableViewController.tmpCMD.removeAll()
                    
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_fail"))
                    
                }
                break
                
            case BPprotocol.cmd_set_user_pwd:
                
                if cmd[4] == BPprotocol.result_success{
                    let cmdData = Array(UserInfoTableViewController.tmpCMD[7...UserInfoTableViewController.tmpCMD.count-1])
                    var pwdArray = [UInt8]()
                    for j in 0 ... BPprotocol.userPD_maxLen - 1{
                        print(String(format:"%02x",cmdData[j]))
                        if cmdData[j] != 0xFF && cmdData[j] != 0x00{
                            pwdArray.append(cmdData[j])
                        }
                    }
                    let pwdStr = String(bytes: pwdArray, encoding: .ascii) ?? ""
                    print("user pwd \(pwdStr)")
                    
                    
                    Config.userListArr[selectUser]["pw"] = pwdStr
                    
                    passwordTextField.text = pwdStr
                    
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_success"))
                    
                    
                    
                }else{
                    UserInfoTableViewController.tmpCMD.removeAll()
                    
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_fail"))
                }
                
                break
            case BPprotocol.cmd_user_del:
                if  cmd[4] == BPprotocol.result_success{
                    
                Config.userListArr.remove(at: self.selectUser)
                
                    _ = self.navigationController?.popViewController(animated: true)
                } else{
                 self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_fail"))
                }
                break
                
            case BPprotocol.cmd_user_property:
                if cmd[1] == BPprotocol.type_read {
                    
                    var data = [UInt8]()
                    for i in 4 ... cmd.count - 1{
                        data.append(cmd[i])
                    }
                    
                    updateUserProperty(propertyData: data)
                    
                }else{
                    if cmd[4] == BPprotocol.result_success{
                        var data = [UInt8]()
                        print(String(format:"tmpbuff len=%d\r\n",UserInfoTableViewController.tmpCMD.count))
                        for i in 7 ... UserInfoTableViewController.tmpCMD.count - 1{
                            data.append(UserInfoTableViewController.tmpCMD[i])
                            print(String(format:"w-data[%d]=%02x",(i - 7), data[i-7]))
                        }
                        
                        updateUserProperty(propertyData: data)
                        
                        self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_success"))
                        UserInfoTableViewController.tmpCMD.removeAll()
                    }else{
                        
                        
                        self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("program_fail"))
                        UserInfoTableViewController.tmpCMD.removeAll()
                    }
                }
                break
                
            default:
                break
            }
        }
    }
    
    func updateUserProperty(propertyData:[UInt8]){
        if propertyData[0] > 0x00 {
            isKeypadCode = true
           
        }else{
            isKeypadCode = false
            
        }
        keypadSwitch.setOn(isKeypadCode, animated: true)
        print(String(format:"keypad=%02x",propertyData[0]))
        
        limitType = propertyData[1]
        print(String(format:"limitType=%02x",propertyData[1]))
        
        label_accessLimit.text = Config.accessTypesArray[Int(limitType)]
        
        var startTime = Array(propertyData[2...8])
        var isFirstSetupUser = 0
        for i in 0 ... startTime.count - 1 {
            if startTime[i] == 0x00{
                isFirstSetupUser += 1
            }
            
            print(String(format:"s time[%d]=%02x",i,startTime[i]))
        }
        
        
        var endTime = Array(propertyData[9...15])
        if isFirstSetupUser == 7{
            let date = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            let sec = calendar.component(.second, from: date)
            
            startTime[0] = UInt8(year >> 8)
            startTime[1] = UInt8(year & 0x00FF)
            startTime[2] = UInt8(month)
            startTime[3] = UInt8(day)
            startTime[4] = UInt8(hour)
            startTime[5] = UInt8(minutes)
            startTime[6] = UInt8(sec)
            for i in 0 ... endTime.count - 1{
                endTime[i] = startTime[i]
            }
        }
        for i in 0 ... endTime.count - 1{
            print(String(format:"e time[%d]=%02x",i,endTime[i]))
        }
        
        openTimes = Int(propertyData[16])
        print(String(format:"time=%02x",propertyData[16]))
        
        weekly = propertyData[17]
        print(String(format:"weekly=%02x",propertyData[17]))
        
        startTimeArr = [Int(UInt16(startTime[0]) * 256 + UInt16(startTime[1])), Int(startTime[2]), Int(startTime[3]), Int(startTime[4]), Int(startTime[5]), Int(startTime[6])]
        
        endTimeArr = [Int(UInt16(endTime[0]) * 256 + UInt16(endTime[1])), Int(endTime[2]), Int(endTime[3]), Int(endTime[4]), Int(endTime[5]), Int(endTime[6])]
        
        /*
        newStartTimeArr = startTimeArr
        newEndTimeArr = endTimeArr
        
        
        dayNtimeView.frame = UIScreen.main.bounds
        weeklyView.frame = UIScreen.main.bounds
        
        datePicker.datePickerMode = .date
        timePicker.datePickerMode = .time
        datePicker.date = Date()
        timePicker.minuteInterval = 1
        
        datePicker.minimumDate = Date()
        formatter.dateFormat = "yyyy/MM/dd"
        timeFormatter.dateFormat = "HH:mm"
        datePicker.maximumDate = formatter.date(from: "2036/12/31")
        
        datePicker.addTarget(self, action: #selector(EditUserViewController.didSelectDate), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(EditUserViewController.didSelectTime), for: .valueChanged)
        
        weekStartTimeField.addTarget(self, action: #selector(EditUserViewController.beginEdit), for: .editingDidBegin)
        weekEndTimeField.addTarget(self, action: #selector(EditUserViewController.beginEdit), for: .editingDidBegin)
        
        startDateField.inputView = datePicker
        startTimeField.inputView = timePicker
        endDateField.inputView = datePicker
        endTimeField.inputView = timePicker
        
        startDateField.text = "\(startTimeArr[0])/\(String(format: "%02d",startTimeArr[1]) )/\(String(format: "%02d",startTimeArr[2]) )"
        startTimeField.text =  String(format: "%02d",startTimeArr[3]) + ":" + String(format: "%02d",startTimeArr[4])
        endDateField.text = "\(endTimeArr[0])/\(String(format: "%02d",endTimeArr[1]))/\(String(format: "%02d",endTimeArr[2]))"
        endTimeField.text = String(format: "%02d",endTimeArr[3]) + ":" + String(format: "%02d",endTimeArr[4])
        
        weekStartTimeField.text = String(format: "%02d",startTimeArr[3]) + ":" +  String(format: "%02d",startTimeArr[4])
        weekEndTimeField.text = String(format: "%02d",endTimeArr[3]) + ":" + String(format: "%02d",endTimeArr[4])
        weekStartTimeField.inputView = timePicker
        weekEndTimeField.inputView = timePicker
        mainTable.reloadData()*/
        
    }
    



}
