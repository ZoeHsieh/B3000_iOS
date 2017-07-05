//
//  SettingsTableViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/12.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit
import UIAlertController_Blocks
import CoreBluetooth

enum settingStatesCase:Int {
    case setting_none = 0
    case config_device = 1
    case config_deviceTime = 2
}
class SettingsTableViewController: BLE_tableViewController {
    
    @IBOutlet weak var usersButton: UIButton!
    @IBOutlet weak var activityHistoryButton: UIButton!
    @IBOutlet weak var backupButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    @IBOutlet var loadingView: UIView!
 
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    @IBOutlet weak var adminPWDLabel: UILabel!
    
    
    @IBOutlet weak var doorSwitch: UISwitch!
    
    @IBOutlet weak var doorActionLabel: UILabel!
    
    
    @IBOutlet weak var tamperSwitch: UISwitch!
    
    @IBOutlet weak var delayTimeLabel: UILabel!
    
    @IBOutlet weak var rssiLabel: UILabel!
    
    @IBOutlet weak var backBar: UINavigationItem!
   
    
    var selectedDevice:CBPeripheral!
    var tmpDeviceName:String?
    //var fwVersion:String = ""
    var newFwVersion:String?
    var tmpAdminPWD:String?
    static var startTimeArr: Array<Int>!
    static var tmpConfig = Data()
    var tmpDeviceTime = Data()
    var currConfig:[UInt8]!
    var fwVersionInt:Float = 0
    var userMax:Int16 = 0
    static var  settingStatus:Int = 0
    @IBOutlet weak var deviceTimeLabel: UILabel!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBAction func backPageListener(_ sender: Any) {
        
       print("backpage")
        switch SettingsTableViewController.settingStatus{
            
            default:
            if fwVersionInt > Config.check_version{
                Config.bleManager.disconnectByCMD(char: bpChar)
            }else{
                
                Config.bleManager.disconnect()
            }
            backToMainPage()
            
            
        
            break
            
            
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        
        usersButton.adjustButtonEdgeInsets()
        activityHistoryButton.adjustButtonEdgeInsets()
        backupButton.adjustButtonEdgeInsets()
        restoreButton.adjustButtonEdgeInsets()
        
        usersButton.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        activityHistoryButton.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        backupButton.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        restoreButton.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
       
    
            tableView.register(R.nib.settingsTableViewSectionFooter)
        
            setUIVisable(enable: false)
        
            Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        
        delayOnMainQueue(delay: 1, closure: {
             Config.bleManager.connect(bleDevice: self.selectedDevice)
            self.deviceNameLabel.text = self.selectedDevice.name
            Config.deviceName =  self.deviceNameLabel.text!
        })
        
    SettingsTableViewController.settingStatus = settingStatesCase.setting_none.rawValue
    }
    
   
    
        
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        switch SettingsTableViewController.settingStatus{
            
        case settingStatesCase.config_device
            .rawValue:
           
            Config.bleManager.writeData(cmd: SettingsTableViewController.tmpConfig, characteristic: bpChar)
           
            break
            
        case settingStatesCase.config_deviceTime.rawValue:
            let timeUInt8 = Util.toUInt8date(SettingsTableViewController.startTimeArr)
            let cmd = Config.bpProtocol.setDeviceTime(deviceTime: timeUInt8)
            
            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
            tmpDeviceTime = cmd
            break
        default:
            
            break
        }
         SettingsTableViewController.settingStatus = settingStatesCase.setting_none.rawValue
    }    
    func setUIVisable(enable:Bool){
        
        usersButton.isHidden = !enable
        activityHistoryButton.isHidden = !enable
        backupButton.isHidden = !enable
        restoreButton.isHidden = !enable
        if !enable {
        self.view.addSubview(loadingView)
             loadingView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 64)
        }else{
        
           loadingView.isHidden = true
         
        }
    }
    @IBAction func didTapUsers(_ sender: Any) {
        //performSegue(withIdentifier: "showUserList", sender: nil)
    }
    
    @IBAction func didTapActivityHistory(_ sender: Any) {
       // let vc = ActivityHistoryViewController(nib: R.nib.activityHistoryViewController)
         //  vc.bpChar = self.bpChar
       // navigationController?.pushViewController(vc, animated: true)
        //performSegue(withIdentifier: "showHistory", sender: nil)
        
    }
    
    @IBAction func didTapBackup(_ sender: Any) {
        
        UIAlertController.showAlert(
            in: self,
            withTitle: "確定要備份資料？",
            message: nil,
            cancelButtonTitle: "Cancel",
            destructiveButtonTitle: nil,
            otherButtonTitles: ["OK"],
            tap: {(controller, action, buttonIndex) in
                if (buttonIndex == controller.cancelButtonIndex) {
                    print("Cancel Tapped")
                } else if (buttonIndex == controller.destructiveButtonIndex) {
                    print("Delete Tapped")
                } else if (buttonIndex >= controller.firstOtherButtonIndex) {
                    print("Other Button Index \(buttonIndex - controller.firstOtherButtonIndex)")
                }
        })
    }
    
    @IBAction func didTapRestore(_ sender: Any) {
        
        UIAlertController.showAlert(
            in: self,
            withTitle: "確定要還原備份資料？",
            message: nil,
            cancelButtonTitle: "Cancel",
            destructiveButtonTitle: nil,
            otherButtonTitles: ["OK"],
            tap: {(controller, action, buttonIndex) in
                if (buttonIndex == controller.cancelButtonIndex) {
                    print("Cancel Tapped")
                } else if (buttonIndex == controller.destructiveButtonIndex) {
                    print("Delete Tapped")
                } else if (buttonIndex >= controller.firstOtherButtonIndex) {
                    print("Other Button Index \(buttonIndex - controller.firstOtherButtonIndex)")
                }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        cell?.selectionStyle = .none;
        return cell!
    }*/
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Config.adminSettingMenuItem
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = Bundle.main.loadNibNamed("MyTableViewSectionHeader",
//                                                  owner: self, options: nil)?[0] as! UIView
////        let titleLabel = headerView.viewWithTag(1) as! UILabel
////        titleLabel.text = self.adHeaders?[section]
//        return headerView
//    }
//    
//    //返回分区头部高度
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.usersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
//        cell.accountLabel.text = "\(accountArr[indexPath.row])"
        
//        return cell
        
//        let footerView = R.nib.settingsTableViewSectionFooter.instantiate(withOwner: nil, options: nil)
//        return footerView
        
        let footerView = R.nib.settingsTableViewSectionFooter.firstView(owner: nil)
        
        return footerView

    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView .deselectRow(at: indexPath, animated: true)
       
        switch indexPath.row
        {
        case 0:
            alertWithTextField(title: self.GetSimpleLocalizedString("settings_device_name_edit"), subTitle: "", placeHolder: deviceNameLabel.text!, keyboard: .default ,Tag: 0,handler: { (inputText) in
                
                guard var newName: String = inputText else{
                    self.showToastDialog(title: "", message: "Wrong format!")
                    
                    return
                }
                //                guard newName.utf8.count < 17 else{
                //                    self.showAlert(message: "Name too long")
                //                    return
                //                }
                let length = newName.utf8.count
                
                if newName.utf8.count > 16{
                    
                    repeat{
                        var chars = newName.characters
                        chars.removeLast()
                        newName = String(chars)
                    }while newName.utf8.count > 16
                }
                
                self.tmpDeviceName = newName
                
                /*while newName.utf8.count < 16{
                 newName = newName + " "
                 }*/
                
                let nameUint8 = Util.StringtoUINT8(data: newName, len: 16, fillData: BPprotocol.nullData)
                
                //Array(newName.utf8)//utf8Name.map{ UInt8($0.value) }
                
                let cmd = Config.bpProtocol.setDeviceName(deviceName:nameUint8, nameLen: newName.utf8.count)
                Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
              
            })
        
        case 1:
            print("fw= \(newFwVersion)")
            let index = newFwVersion?.index((newFwVersion?.startIndex)!, offsetBy: 1)
            let fwVR = newFwVersion?.substring(from:index!)
            let currentVR:Float = Float(fwVR!)!
            var checkFlag:Bool = false
            print("fw= \(currentVR)")
            if currentVR > Config.check_version {
                checkFlag = true
            }
            if Config.isUserListOK || checkFlag {
                alertWithTextField(title: self.GetSimpleLocalizedString("settings_Admin_pwd_Edit"), subTitle: "", placeHolder: adminPWDLabel.text!, keyboard: .numberPad, Tag: 1, handler: { (inputText) in
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
                        
                        self.tmpAdminPWD = newPWD
                        
                        
                        let pwdUint8 = Util.StringtoUINT8(data: newPWD, len: BPprotocol.userPD_maxLen, fillData: BPprotocol.nullData)
                        
                        
                        
                        let cmd = Config.bpProtocol.setAdminPWD(Password: pwdUint8)
                        Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
                        
                        for j in 0 ... cmd.count - 1{
                            
                            print(String(format:"%02x ",cmd[j]))
                        }
                       
                    }else{
                     self.showToastDialog(title: "", message: "wrong format!")
                    } })
            }
        case 2:
            
           let delayTime = Int16(currConfig[2]) * 256 + Int16(currConfig[3])
           if currConfig[0] <= 0x00{
            currConfig[0] = 0x01
           }else{
            currConfig[0] = 0x00
           }
           let cmd = Config.bpProtocol.setDeviceConfig(door_option: currConfig[0], lockType: currConfig[1], delayTime: delayTime, G_sensor_option: currConfig[4])
           Config.bleManager
             .writeData(cmd: cmd, characteristic: bpChar!)
            SettingsTableViewController.tmpConfig = cmd
        case 3:
            let vc = DoorLockActionViewController(nib: R.nib.doorLockActionViewController)
            navigationController?.pushViewController(vc, animated: true)
        
        case 4:
           
            if currConfig[4] <= 0x00{
                currConfig[4] = 0x01
            }else
            {
                currConfig[4] = 0x00
            }
            let delayTime = Int16(currConfig[2]) * 256 + Int16(currConfig[3])
            let cmd = Config.bpProtocol.setDeviceConfig(door_option: currConfig[0], lockType: currConfig[1], delayTime: delayTime, G_sensor_option: currConfig[4])
            Config.bleManager
                .writeData(cmd: cmd, characteristic: bpChar!)
             SettingsTableViewController.tmpConfig = cmd
        case 5:/*
            let vc = DoorRe_lockTimeViewController(nib: R.nib.doorReLockTimeViewController)
            navigationController?.pushViewController(vc, animated: true)*/
            
             alertWithTextField(title: "請輸入上鎖時間（1~1800秒）"/*self.GetSimpleLocalizedString("settings_Admin_pwd_Edit")*/, subTitle: "", placeHolder: delayTimeLabel.text!, keyboard: .numberPad, Tag: 2, handler: { (inputText) in
                guard let newDelayTime: String = inputText else{
                    
                    //self.showAlert(message: "Wrong format!")
                    return
                }
                
                if !((inputText?.isEmpty)!){
                    
                  
                    let delayTime = Int16(newDelayTime)
                    
                    let cmd = Config.bpProtocol.setDeviceConfig(door_option: self.currConfig[0], lockType: self.currConfig[1], delayTime: delayTime!, G_sensor_option: self.currConfig[4])
                    Config.bleManager
                        .writeData(cmd: cmd, characteristic: self.bpChar!)
                    SettingsTableViewController.tmpConfig = cmd
                    
                    
                }else{
                    self.showToastDialog(title: "", message: "wrong format!")
                } })

        case 6:
         let vc = ProximityReadRangeViewController(nib: R.nib.proximityReadRangeViewController)
            navigationController?.pushViewController(vc, animated: true)
            
        case 7:
            let vc = DeviceTimeViewController(nib: R.nib.deviceTimeViewController)
            navigationController?.pushViewController(vc, animated: true)
        
        case 8:
            let vc = AboutUsViewController(nib: R.nib.aboutUsViewController)
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
    

   
    
    
    public override func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            Config.bleManager.connect(bleDevice: selectedDevice)
        
    }
    
    public override func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        super.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: error)
        
        var cmd = Data()
        
        
        //if !isErase{
            cmd = Config.bpProtocol.setAdminLogin()
            
            for j in 0 ... cmd.count - 1 {
                
                print(String(format:"%02X",cmd[j]))
            }
            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
            
        //}

        
    }
    
    
    override func cmdAnalysis(cmd:[UInt8]){
        let datalen = Int16( UInt16(cmd[2]) << 8 | UInt16(cmd[3] & 0x00FF))
        /* for i in 0 ... cmd.count - 1{
         print(String(format:"r-cmd[%d]=%02x\r\n",i,cmd[i]))
         }*/
        if datalen == Int16(cmd.count - 4) {
            switch cmd[0]{
            case BPprotocol.cmd_admin_login:
                
               // if cmd[4] == BPprotocol.result_success{
                    let cmd = Config.bpProtocol.getUserCount()
                    Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                    
                   
                    //DeviceData.sharedInstance.isHistoryDataOK = false
                    
                    
              //  }else{
                   // Config.bleManager.disconnect()
                   // DeviceData.sharedInstance.clearAllData()
               //     backToMainPage()
                //}
                
                break
                
            case BPprotocol.cmd_device_config:
                SettingsTableViewController.tmpConfig.append(UInt8(0xC0))
                for i in 0 ... cmd.count - 1{
                    SettingsTableViewController.tmpConfig.append(cmd[i])
                 }
                SettingsTableViewController.tmpConfig.append(UInt8(0xC0))
                if cmd[1] == BPprotocol.type_read {
                    for j in 0 ... 4 {
                        
                        print(String(format:"config=%02X",(cmd[j+4])))
                    }
                    var data:[UInt8] = []
                    for i in 0...Int(datalen) - 1{
                        data.append(cmd[i + 4])
                    }
                    
                    UI_updateDevConfig(data: data)
                    setUIVisable(enable: true)
                }
            else{
                
                for j in 0 ... (SettingsTableViewController.tmpConfig.count) - 1 {
                    
                    print(String(format:"tmp=%02X",(SettingsTableViewController.tmpConfig[j])))
                }
                if cmd[4] == BPprotocol.result_success{
                    var tmpData = [UInt8]()
                    for i in 5 ... (SettingsTableViewController.tmpConfig.count) - 1 {
                        tmpData.append(SettingsTableViewController.tmpConfig[i])
                    }
                    UI_updateDevConfig(data: tmpData)
                    showToastDialog(title:"",message:"success"/*GetSimpleLocalizedString("program_success")*/)
                }else{
                    showToastDialog(title:"",message:"fail"/*GetSimpleLocalizedString("program_fail")*/)
                }

                }
            case BPprotocol.cmd_user_counter:
               /* if isbackup{
                    let userMax = Int(Int16( UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF)))
                    backupMax = userMax + 2//3
                    
                    showProgressDialog(Title:GetSimpleLocalizedString("backup_dialog_title"), Message:GetSimpleLocalizedString("backup_dialog_message"),countMax: backupMax)
                    /* let cmd = bpProtocol.getDeviceName()
                     writeData(cmd: cmd, characteristic: bpChar!)*/
                    let cmd = bpProtocol.getDeviceConfig()
                    writeData(cmd: cmd, characteristic: bpChar!)
                    
                }else{*/
                    
                     userMax = Int16( UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF))
                    print("user Max =%d",userMax)
                    if userMax == 0 {
                        Config.isUserListOK = true
                    }
                    
                    let cmd = Config.bpProtocol.getAdminPWD()
                    Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                    
                //}
                
                break
                
                
            case BPprotocol.cmd_device_name:
                if cmd[1] == BPprotocol.type_write {
                    
                    if cmd[4] == BPprotocol.result_success{
                       
                        print("set device name ok")
                        deviceNameLabel.text  = tmpDeviceName!
                      
                        
                        
                        
                    }
                    Config.deviceName =  deviceNameLabel.text!
                }
                
                break
              /*
            case BPprotocol.cmd_user_data:
              
                if cmd[1] == BPprotocol.type_read{
                    if isbackup{
                        print("user data read")
                        if cmd[4] != 0xFF /*&& cmd[4] != 0x00*/ {
                            
                            for i in 4 ... cmd.count - 1{
                                DeviceData.sharedInstance.userDataArr.append(cmd[i])
                            }
                            
                            print(String(format:"b_cnt=%d\r\n",backupCount))
                            
                            backupCount += 1
                            updateBackupDialog()
                            if backupCount >= backupMax{
                                
                                isbackup = false
                                self.progressView.removeFromSuperview();
                                UserDefaults.standard.set(DeviceData.sharedInstance.userDataArr, forKey: DeviceData.User_ListTag_backup)
                                
                                UserDefaults.standard.set(true, forKey: DeviceData.backupOK)
                                
                            }else{
                                
                                
                                let cmd = bpProtocol.getUserData(UserCount: backupCount - 2)
                                writeData(cmd: cmd, characteristic: bpChar!)
                            }
                            
                            
                        }
                    }
                    
                }else{
                    restoreCount += 1
                    updateRestoreDialog()
                    
                    if restoreCount >= restoreMax {
                        self.progressView.removeFromSuperview();
                        
                        
                    }else{
                        let user_addr = (restoreCount - 3/*4*/) * BPprotocol.userDataSize
                        
                        print(String(format:"addr=%d\r\n", user_addr))
                        print(String(format:"array cnt=%d\r\n", DeviceData.sharedInstance.userDataArr.count))
                        var userData = [UInt8]()
                        for i in 0 ... BPprotocol.userDataSize - 1{
                            
                            userData.append(DeviceData.sharedInstance.userDataArr[user_addr+i])
                            
                            print(String(format:"data[%d]=%02X\r\n",i,userData[i]))
                            
                            
                        }
                        let cmd = bpProtocol.setUserData(UserData: userData)
                        writeData(cmd:cmd,characteristic: bpChar!)
                    }
                    
                    
                }
                break*/
           
            case BPprotocol.cmd_set_admin_pwd:
                
                for i in 0 ... cmd.count - 1{
                    print(String(format:"cmd[%d]=%02x",i,cmd[i]))
                }
                if cmd[1] == BPprotocol.type_write{
                    if cmd[4] == BPprotocol.result_success{
                        
                        print(tmpAdminPWD)
                       adminPWDLabel.text = tmpAdminPWD
                      
                    }
                        /*if isRestore{
                            restoreCount += 1
                            updateRestoreDialog()
                            /*let nameUint8 = Util.StringtoUINT8(data: DeviceData.sharedInstance.deviceName!, len: 16, fillData: BPprotocol.nullData)
                             
                             let cmd = bpProtocol.setDeviceName(deviceName: nameUint8, nameLen: (DeviceData.sharedInstance.deviceName?.characters.count)!)
                             writeData(cmd: cmd, characteristic: bpChar!)*/
                            let cmd = bpProtocol.setEraseUserList()
                            writeData(cmd:cmd,characteristic: bpChar!)
                            isErase = true
                            
                        }else{
                            
                            print(tmpAdminPWD)
                            newAdminPWD = tmpAdminPWD
                            mainTable.reloadData()
                            DeviceData.sharedInstance.adminPWD =  newAdminPWD
                        }
                    }*/
                }else{
                    var data = [UInt8]()
                    for i in 4 ... cmd.count - 1{
                        data.append(cmd[i])
                    }
                    var PWDArray = [UInt8]()
                    
                    for j in 0 ... BPprotocol.userPD_maxLen - 1{
                        if  data[j] != 0xFF && data[j] != 0x00{
                            PWDArray.append(data[j])
                        }
                    }
                    let pwd = String(bytes: PWDArray, encoding: .ascii) ?? "12345"
                    
                    print(pwd)
                    
                    /*if isbackup {
                        DeviceData.sharedInstance.adminPWD = pwd
                        UserDefaults.standard.set( pwd, forKey: DeviceData.ADMIN_PWDTag_backup)
                        backupCount += 1
                        DeviceData.sharedInstance.userDataArr.removeAll()
                        updateBackupDialog()
                        if backupMax > 2/*3*/ {
                            
                            print(String(format:"backup=%d\r\n",backupCount - 1/*2*/))
                            let cmd = bpProtocol.getUserData(UserCount: backupCount - 1/*2*/)
                            writeData(cmd: cmd, characteristic: bpChar!)
                        }
                        else
                        {   DeviceData.sharedInstance.userDataArr.removeAll()
                            UserDefaults.standard.set(DeviceData.sharedInstance.userDataArr, forKey: DeviceData.User_ListTag_backup)
                            
                            
                            UserDefaults.standard.set(true, forKey: DeviceData.backupOK)
                            self.progressView.removeFromSuperview();
                            isbackup = false
                        }*/
                   // }else{
                        
                        
                         adminPWDLabel.text = pwd
                    
                        //DeviceData.sharedInstance.adminPWD =  newAdminPWD
                    
                        let cmd = Config.bpProtocol.getFW_version()
                        Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                        
                    //}
                }
                Config.ADMINPWD = adminPWDLabel.text!
                break
                
            case BPprotocol.cmd_fw_version:
                
                if cmd[1] == BPprotocol.type_read{
                    
                    var data = [UInt8]()
                    for i in 4 ... cmd.count - 1{
                        data.append(cmd[i])
                    }
                    let major = data[0]
                    let minor = data[1]
                    fwVersionInt = Float(major) + (Float(minor) * 0.01)
                    newFwVersion = String(format:"V%d.%02d",major,minor)
                   let footerView = R.nib.settingsTableViewSectionFooter.firstView(owner: nil)
                    footerView?.setVersion(version: newFwVersion!)
                    tableView.reloadData()
                   /* if major == 1 && minor >= 6{
                        isCmdDisCon = true
                    }else{
                        isCmdDisCon = false
                    }*/
                    let cmd = Config.bpProtocol.getDeviceTime()
                    Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                    
                }
                
                
                break
                
            case BPprotocol.cmd_device_time:
                
               
                if cmd[1] == BPprotocol.type_read{
                    var data = [UInt8]()
                    for i in 4 ... cmd.count - 1{
                        data.append(cmd[i])
                    }
                    let y = UInt16(data[0]) * 256 + UInt16(data[1])
                    let m = data[2].toTimeString()
                    let d = data[3].toTimeString()
                    let hh = data[4].toTimeString()
                    let mm = data[5].toTimeString()
                    let ss = data[6].toTimeString()
                    let timeText = "\(y)-\(m)-\(d) \(hh):\(mm):\(ss)"
             
                    SettingsTableViewController.startTimeArr = [Int(UInt16(data[0]) * 256 + UInt16(data[1])), Int(data[2]), Int(data[3]), Int(data[4]), Int(data[5]), Int(data[6])]
                   
                   deviceTimeLabel.text = "\(d)-\(m)-\(y) \(hh):\(mm):\(ss)"
                   
                    
                    let cmd = Config.bpProtocol.getDeviceConfig()
                    Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                }else{
                 
                    if cmd[4] == BPprotocol.result_success{
                        
                        var data = [UInt8] ()
                        for i in 5 ... tmpDeviceTime.count - 2{
                            data.append(tmpDeviceTime[i])
                        }
                        
                        SettingsTableViewController.startTimeArr = [Int(UInt16(data[0]) * 256 + UInt16(data[1])), Int(data[2]), Int(data[3]), Int(data[4]), Int(data[5]), Int(data[6])]
                        
                        
                        let y = UInt16(data[0]) * 256 + UInt16(data[1])
                        let m = data[2].toTimeString()
                        let d = data[3].toTimeString()
                        let hh = data[4].toTimeString()
                        let mm = data[5].toTimeString()
                        let ss = data[6].toTimeString()
                        let timeText = "\(y)-\(m)-\(d) \(hh):\(mm):\(ss)"
                        
                         deviceTimeLabel.text = timeText
                        showToastDialog(title:"",message:GetSimpleLocalizedString("program_success"))
                       
                    }else{
                        showToastDialog(title:"",message:GetSimpleLocalizedString("program_fail"))
                    }
                    
                }
                
                
                break
                /*
            case BPprotocol.cmd_erase_users:
                restoreCount += 1
                print("restoreCount")
                print("restoreCount= \(restoreCount)")
                updateRestoreDialog()
                
                if restoreMax > 3/*4*/ {
                    let user_addr = (restoreCount - 3/*4*/) * BPprotocol.userDataSize
                    
                    
                    let userIndex = Int16((UInt16(DeviceData.sharedInstance.userDataArr[user_addr]) << 8 ) | (UInt16(DeviceData.sharedInstance.userDataArr[user_addr+1]) & 0x00FF))
                    var userData = [UInt8]()
                    for i in 0 ... BPprotocol.userDataSize - 1{
                        
                        userData.append(DeviceData.sharedInstance.userDataArr[user_addr+i])
                        
                        
                    }
                    let cmd = bpProtocol.setUserData( UserData: userData)
                    writeData(cmd:cmd,characteristic: bpChar!)
                }else{
                    self.progressView.removeFromSuperview();
                    
                    
                }
                break*/
                
                
            default:
                break
                
            }
        }

    }
    
    func UI_updateDevConfig( data:[UInt8]){
        
        if data[0] != 0x00{
            doorSwitch.setOn(true, animated: false)
        }else{
            doorSwitch.setOn(false, animated: false)
        }
        let index:Int = Int(data[1])
        doorActionLabel.text = Config.doorActionItem[index]
        delayTimeLabel.text = String(format:"%d",UInt16(data[2]) * 256 + UInt16(data[3]))
        
        if data[4] != 0x00{
            tamperSwitch.setOn(true, animated: false)
        }else{
          tamperSwitch.setOn(false, animated: false)
        }
        currConfig = data
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showUserList"){
            let nvc = segue.destination  as!
            UsersViewController
            ///let vc = nvc.topViewController as! Intro_PasswordViewController
            nvc.userMax = self.userMax
            nvc.bpChar =  self.bpChar
        }else if (segue.identifier == "showHistory"){
            let nvc = segue.destination  as!
            ActivityHistoryViewController
            nvc.bpChar = self.bpChar
        
        }
       
        
        
    }
}
