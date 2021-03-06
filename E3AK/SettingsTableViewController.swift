//
//  SettingsTableViewController.swift
//  E3AK
//
//  Created by BluePacket on 2017/6/12.
//  Copyright © 2017年 BluePacket. All rights reserved.
//

import UIKit
import UIAlertController_Blocks
import CoreBluetooth

protocol PassDataDelegate {
    func setcurrentdate()
}

enum settingStatesCase:Int {
    case setting_none = 0
    case config_device = 1
    case config_deviceTime = 2
}
class SettingsTableViewController: BLE_tableViewController,PassDataDelegate {
    
    @IBOutlet weak var usersButton: UIButton!
    @IBOutlet weak var activityHistoryButton: UIButton!
    @IBOutlet weak var backupButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    @IBOutlet var loadingView: UIView!
    
    @IBOutlet weak var deviceNameTitle: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var adminPWDTitle: UILabel!
    
    @IBOutlet weak var adminPWDLabel: UILabel!
    
    @IBOutlet weak var doorSwitchTitle: UILabel!
    
    @IBOutlet weak var doorSwitch: UISwitch!
    
    @IBOutlet weak var doorActionTitle: UILabel!
    @IBOutlet weak var doorActionLabel: UILabel!
    
    @IBOutlet weak var tamperSwitchTitle: UILabel!
    
    @IBOutlet weak var tamperSwitch: UISwitch!
    
    @IBOutlet weak var delayTimeTitle: UILabel!
    
    @IBOutlet weak var delayTimeLabel: UILabel!
    
    @IBOutlet weak var rssiTitle: UILabel!
    
    @IBOutlet weak var rssiLabel: UILabel!
    
    @IBOutlet weak var deviceTimeTitle: UILabel!
    
    @IBOutlet weak var aboutTitle: UILabel!
    
    @IBOutlet weak var backBar: UINavigationItem!
    
    @IBOutlet weak var label_progress_dg_title: UILabel!
    
    @IBOutlet weak var label_progress_dg_msg: UILabel!
    @IBOutlet weak var pg_bar_progress_dg_view: UIProgressView!
    
    @IBOutlet weak var label_progress_dg_percent: UILabel!
    
    @IBOutlet weak var label_progress_dg_count: UILabel!
    
    
    @IBOutlet weak var downloadFrame: UIView!
    @IBOutlet weak var downloadView: UIView!
    
    @IBOutlet var msgFrame: UIView!
    @IBOutlet var msgView: UIView!
    
    @IBOutlet weak var label_msg_dg_title: UILabel!
    
    @IBOutlet weak var label_msg_dg_msg: UILabel!
    
    
    
    
    
    
    @IBAction func progress_cancel_Action(_ sender: Any) {
        if isRestore{
            isRestore = false
            isErase = false
            if fwVersionInt > Config.check_version{
                Config.bleManager.disconnectByCMD(char: bpChar)
            }else{
                
                Config.bleManager.disconnect()
            }
            
            backToMainPage()
            self.restoreCount = 0;
        }else{
            self.backupCount = 0;
            isCancel = true
        }
        self.msgFrame.removeFromSuperview();
        
        
    }
    @IBAction func msg_dg_okAction(_ sender: Any) {
        
        self.msgFrame.removeFromSuperview()
        self.backupCount = 0;
        self.backupMax = 0
        
        if isRestore{
            isRestore = false
            isErase = false
            if fwVersionInt > Config.check_version{
                Config.bleManager.disconnectByCMD(char: bpChar)
            }else{
                
                Config.bleManager.disconnect()
            }
            self.backToMainPage()
        }
        
        
    }
    
    
    var selectedDevice:CBPeripheral!
    var tmpDeviceName:String?
    //var fwVersion:String = ""
    var newFwVersion:String? =  ""
    var tmpAdminPWD:String?
    static var startTimeArr: Array<Int>!
    static var tmpConfig = Data()
    var tmpDeviceTime = Data()
    var currConfig:[UInt8]!
    var fwVersionInt:Float = 0
    var userMax:Int16 = 0
    var isbackup = false
    var backupMax:Int16 = 0
    var backupCount:Int16 = 0
    var restoreCount:Int16 = 0
    var restoreMax:Int16 = 0
    var isRestore = false
    var isErase = false
    var isCancel = false
    var dateFormatter = DateFormatter()
    static var  settingStatus:Int = 0
    var connectTimer:Timer? = nil
    @IBOutlet weak var deviceTimeLabel: UILabel!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBAction func backPageListener(_ sender: Any) {
        
        
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
        
        title = GetSimpleLocalizedString("Settings")
        usersButton.setTitle(GetSimpleLocalizedString("Users"), for: .normal)
        activityHistoryButton.setTitle(GetSimpleLocalizedString("Activity History"), for: .normal)
        backupButton.setTitle(GetSimpleLocalizedString("Backup"), for: .normal)
        restoreButton.setTitle(GetSimpleLocalizedString("Restore"), for: .normal)
        deviceNameTitle.text = GetSimpleLocalizedString("Device Name")
        adminPWDTitle.text = GetSimpleLocalizedString("settings_Admin_pwd")
        doorSwitchTitle.text = GetSimpleLocalizedString("Door Sensor")
        doorActionTitle.text = GetSimpleLocalizedString("Door Lock Action")
        delayTimeTitle.text = GetSimpleLocalizedString("Use Re-lock Time")
        tamperSwitchTitle.text = GetSimpleLocalizedString("Tamper Sensor")
        rssiTitle.text = GetSimpleLocalizedString("Proximity Read Range")
        
        deviceTimeTitle.text = GetSimpleLocalizedString("Device Time")
        aboutTitle.text = GetSimpleLocalizedString("About Us")
        
        usersButton.adjustButtonEdgeInsets()
        activityHistoryButton.adjustButtonEdgeInsets()
        backupButton.adjustButtonEdgeInsets()
        restoreButton.adjustButtonEdgeInsets()
        
        usersButton.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        activityHistoryButton.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        backupButton.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        restoreButton.setShadowWithColor(color: UIColor.gray, opacity: 0.3, offset: CGSize(width: 0, height: 3), radius: 2, viewCornerRadius: 2.0)
        
        dateFormatter.dateStyle = .medium // show short-style date format
        dateFormatter.timeStyle = .short
        tableView.register(R.nib.settingsTableViewSectionFooter)
        
        setUIVisable(enable: false)
        
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        
        delayOnMainQueue(delay: 1, closure: {
            Config.bleManager.connect(bleDevice: self.selectedDevice)
            self.StartConnectTimer()
            self.deviceNameLabel.text = self.selectedDevice.name
            Config.deviceName =  self.deviceNameLabel.text!
        })
        
        SettingsTableViewController.settingStatus = settingStatesCase.setting_none.rawValue
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
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
            rssiLabel.text = String(format:"%d",readExpectLevelFromDbByUUID(selectedDevice.identifier.uuidString))
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
            withTitle: self.GetSimpleLocalizedString("Backup all data now?"),
            message: nil,
            cancelButtonTitle: self.GetSimpleLocalizedString("Cancel"),
            destructiveButtonTitle: nil,
            otherButtonTitles: [self.GetSimpleLocalizedString("Confirm")],
            tap: {(controller, action, buttonIndex) in
                if (buttonIndex == controller.cancelButtonIndex) {
                    print("Cancel Tapped")
                } else if (buttonIndex == controller.destructiveButtonIndex) {
                    print("Delete Tapped")
                } else if (buttonIndex >= controller.firstOtherButtonIndex) {
                    self.isbackup = true
                    self.backupMax = 0
                    self.backupCount = 0
                    
                    let cmd = Config.bpProtocol.getUserCount()
                    Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar!)
                    
                    
                }
        })
    }
    
    @IBAction func didTapRestore(_ sender: Any) {
        
        
        
        let isBackupDone:Bool = UserDefaults.standard.bool(forKey: Config.backupOK)
        
        
        if isBackupDone{
            let alertController = UIAlertController(title: self.GetSimpleLocalizedString("Restore all data now?"), message: "", preferredStyle: .alert)
            
            let enableAction = UIAlertAction(title: self.GetSimpleLocalizedString("Confirm"), style: .default, handler: { action in
                
                self.isRestore = true
                self.restoreCount = 0
                
                Config.userDataArr.removeAll()
                Config.userDataArr = (UserDefaults.standard.object(forKey: Config.User_ListTag_backup) as? [UInt8])!
                let userMax:Int16 = Int16(Config.userDataArr.count/BPprotocol.userDataSize)
                print("twtwtwtwtw\(Config.userDataArr.count)")
                print("twtwtwtwtw\(BPprotocol.userDataSize)")
                print("twtwtwtwtw\(userMax)")
                print(String(format:"userMax=%d\r\n",userMax))
                self.restoreMax = userMax + 3/*4*/
                
                self.showProgressDialog(Title:self.GetSimpleLocalizedString("restore_dialog_title"), Message:self.GetSimpleLocalizedString("restore_dialog_message"), countMax: self.restoreMax)
                var dataDict = UserDefaults.standard.object(forKey: Config.ConfigTag_backup) as? [String:Any]?
                
                //DeviceConfig
                Config.doorSensor = dataDict??[Config.ConfigDoorSensorTag] as? UInt8
                Config.doorLockType = dataDict??[Config.ConfigDoorLockTypeTag]  as? UInt8
                Config.doorOpenTime = dataDict??[Config.ConfigDoorOpenTimeTag] as? UInt16
                Config.TamperSensor = dataDict??[Config.ConfigGSensorTag] as? UInt8
                Config.ADMINPWD = (UserDefaults.standard.object(forKey: Config.ADMIN_PWDTag_backup) as? String)!
                //DeviceData.sharedInstance.deviceName = (UserDefaults.standard.object(forKey: DeviceData.DeviceNameTag_backup) as? String)!
                let cmd = Config.bpProtocol.setDeviceConfig(door_option: Config.doorSensor! , lockType: Config.doorLockType!, delayTime: Int16(Config.doorOpenTime!), G_sensor_option: Config.TamperSensor!)
                Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar!)
                
                
                
                
            })
            
            let cancelAction = UIAlertAction(title: self.GetSimpleLocalizedString("Cancel"), style: .cancel, handler: nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(enableAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            
            self.showMessageDialog(Title: "", Message: self.GetSimpleLocalizedString("restore_status_file_not_found"))
            
        }
        
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
        footerView?.setVersion(version: newFwVersion!)
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
            alertWithTextField(title: self.GetSimpleLocalizedString("Edit Device Name"), subTitle: "", placeHolder: self.GetSimpleLocalizedString("Up to 16 characters"), keyboard: .default, defaultValue: deviceNameLabel.text! ,Tag: 0,handler: { (inputText) in
                
                guard var newName: String = inputText else{
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("Wrong format!"))
                    
                    return
                }
                //                guard newName.utf8.count < 17 else{
                //                    self.showAlert(message: "Name too long")
                //                    return
                //                }
                let length = newName.utf8.count
                
                if newName.utf8.count > 16{
                    
                    repeat{
                        var chars = newName
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
                alertWithTextField(title: self.GetSimpleLocalizedString("settings_Admin_pwd_Edit"), subTitle: "", placeHolder: self.GetSimpleLocalizedString("4~8 digits"), keyboard: .numberPad, defaultValue: adminPWDLabel.text!, Tag: 1, handler: { (inputText) in
                    guard let newPWD: String = inputText else{
                        
                        //self.showAlert(message: "Wrong format!")
                        return
                    }
                    if !((inputText?.isEmpty)!){
                        guard (inputText?.count)! > 3 && (inputText?.count)! < BPprotocol.userPD_maxLen+1 else{
                            
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
                        self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("wrong format!"))
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
            
            alertWithTextField(title:self.GetSimpleLocalizedString( "Edit Door Re-lock Time (1~1800 seconds)"), subTitle: "", placeHolder: "1~1800", keyboard: .numberPad, defaultValue: delayTimeLabel.text!, Tag: 2, handler: { (inputText) in
                guard let newDelayTime: String = inputText else{
                    
                    //self.showAlert(message: "Wrong format!")
                    return
                }
                
                if !((inputText?.isEmpty)!){
                    
                    
                    let delayTime = Int16(newDelayTime)
                    if delayTime! > 0 && delayTime! <= 1800 {
                        let cmd = Config.bpProtocol.setDeviceConfig(door_option: self.currConfig[0], lockType: self.currConfig[1], delayTime: delayTime!, G_sensor_option: self.currConfig[4])
                        Config.bleManager
                            .writeData(cmd: cmd, characteristic: self.bpChar!)
                        SettingsTableViewController.tmpConfig = cmd
                    }
                    
                }else{
                    self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("wrong format!"))
                } })
            
        case 6:
            let vc = ProximityReadRangeViewController(nib: R.nib.proximityReadRangeViewController)
            vc.selectedDevice = selectedDevice
            navigationController?.pushViewController(vc, animated: true)
            
        case 7:
            //            let vc = DeviceTimeViewController(nib: R.nib.deviceTimeViewController)
            //            navigationController?.pushViewController(vc, animated: true)
            let datepicker = WSDatePickerView(dateStyle: DateStyleShowYearMonthDayHourMinute) { (Date) in
                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from: Date! )
                SettingsTableViewController.startTimeArr[0] = dateComponents.year!
                SettingsTableViewController.startTimeArr[1] = dateComponents.month!
                SettingsTableViewController.startTimeArr[2] = dateComponents.day!
                SettingsTableViewController.startTimeArr[3] = dateComponents.hour!
                SettingsTableViewController.startTimeArr[4] = dateComponents.minute!
                SettingsTableViewController.startTimeArr[5] = dateComponents.second!
                
                let timeUInt8 = Util.toUInt8date(SettingsTableViewController.startTimeArr)
                let cmd = Config.bpProtocol.setDeviceTime(deviceTime: timeUInt8)
                
                Config.bleManager.writeData(cmd: cmd, characteristic: self.bpChar)
                self.tmpDeviceTime = cmd
            }
            datepicker?.dateLabelColor =  UIColor(red: 0.0, green: 185.0/255.0, blue: 1.0/255.0, alpha: 1.0)//年-月-日-时-分 颜色
            datepicker?.datePickerColor = UIColor.black //滚轮日期颜色
            datepicker?.doneButtonColor = UIColor(red: 0.0, green: 185.0/255.0, blue: 1.0/255.0, alpha: 1.0);//确定按钮的颜色
            //    datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
            datepicker?.doneButtonText = GetSimpleLocalizedString("Confirm")
            datepicker?.show()
            
        case 8:
            let vc = AboutUsViewController(nib: R.nib.aboutUsViewController)
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
    
    
    
    
    
    public override func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Config.bleManager.connect(bleDevice: selectedDevice)
        StartConnectTimer()
        
    }
    
    public override func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        connectTimer?.invalidate()
        connectTimer = nil
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
                
                if cmd[4] == BPprotocol.result_success{
                    let cmd = Config.bpProtocol.getUserCount()
                    Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                    
                    
                    Config.isHistoryDataOK = false
                    isbackup = false
                    isRestore = false
                    isErase = false
                }else{
                    Config.saveParam.set(false, forKey: selectedDevice.identifier.uuidString)
                    Config.bleManager.disconnect()
                    Config.userDataArr.removeAll()
                    Config.userListArr.removeAll()
                    Config.historyListArr.removeAll()
                    backToMainPage()
                }
                
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
                    
                    if isbackup{
                        if !isCancel {
                            Config.doorSensor = cmd[4]
                            Config.doorLockType = cmd[5]
                            Config.doorOpenTime = UInt16(cmd[6]) * 256 + UInt16(cmd[7])
                            
                            Config.TamperSensor = cmd[8]
                            
                            let dict: [String : Any] = [
                                Config.ConfigDoorSensorTag    :Config.doorSensor ?? 0,
                                Config.ConfigDoorLockTypeTag  :Config.doorLockType ?? 0,
                                Config.ConfigDoorOpenTimeTag  :Config.doorOpenTime ?? 0,
                                Config.ConfigGSensorTag      :Config.TamperSensor ?? 0,
                                Config.ConfigADMIN_MACTag      :Config.userMac
                            ]
                            UserDefaults.standard.set(dict, forKey: Config.ConfigTag_backup)
                            backupCount += 1
                            updateBackupDialog()
                            let cmd = Config.bpProtocol.getAdminPWD()
                            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                        }
                        
                    }else{
                        
                        UI_updateDevConfig(data: data)
                        setUIVisable(enable: true)
                        
                        self.setcurrentdate()
                        
                        
                        let userLanguages = UserDefaults.standard.object(forKey: "AppleLanguages") as! [String]
                        if let userLanguage = userLanguages.first
                        {
                            print(userLanguage)
                            let startIndex = userLanguage.index(userLanguage.startIndex, offsetBy: 0)
                            let endIndex = userLanguage.index(userLanguage.startIndex, offsetBy: 1)
                            let subStr = userLanguage[startIndex...endIndex]
                            
                            if (subStr == "en" || subStr == "it" || subStr == "fr" || subStr == "ja" || subStr == "es")
                            {
                                let img = UIImage(named: "instruction")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                                let bar_item_bt_instruction : UIBarButtonItem = UIBarButtonItem(image: img, style: UIBarButtonItem.Style.plain, target: self, action: #selector(showMasterFAQ))
                                
                                //        bar_item_bt_instruction.imageInsets = UIEdgeInsetsMake(0, 32, 0, -32)
                                self.navigationItem.rightBarButtonItem = bar_item_bt_instruction
                                //        self.navigationItem.rightBarButtonItems = [flexible,bar_item_bt_instruction]
                            }
                        }
                        
                        
                        
                    }
                }
                else{
                    
                    if isRestore{
                        restoreCount += 1
                        updateRestoreDialog()
                        let pwdUint8 = Util.StringtoUINT8(data: Config.ADMINPWD, len: BPprotocol.userPD_maxLen, fillData: BPprotocol.nullData)
                        let cmd = Config.bpProtocol.setAdminPWD(Password: pwdUint8)
                        Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                        
                    }else{
                        for j in 0 ... (SettingsTableViewController.tmpConfig.count) - 1 {
                            
                            print(String(format:"tmp=%02X",(SettingsTableViewController.tmpConfig[j])))
                        }
                        if cmd[4] == BPprotocol.result_success{
                            var tmpData = [UInt8]()
                            for i in 5 ... (SettingsTableViewController.tmpConfig.count) - 1 {
                                tmpData.append(SettingsTableViewController.tmpConfig[i])
                            }
                            UI_updateDevConfig(data: tmpData)
                            // showToastDialog(title:"",message:GetSimpleLocalizedString("program_success"))
                        }else{
                            //showToastDialog(title:"",message: GetSimpleLocalizedString("program_fail"))
                        }
                        
                    }
                }
            case BPprotocol.cmd_user_counter:
                if isbackup{
                    let userMax = Int(Int16( UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF)))
                    backupMax = Int16(userMax + 2)//3
                    
                    showProgressDialog(Title:GetSimpleLocalizedString("backup_dialog_title"), Message:GetSimpleLocalizedString("backup_dialog_message"),countMax: backupMax)
                    /* let cmd = bpProtocol.getDeviceName()
                     writeData(cmd: cmd, characteristic: bpChar!)*/
                    let cmd = Config.bpProtocol.getDeviceConfig()
                    Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                    
                }else{
                    
                    userMax = Int16( UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF))
                    print("user Max =%d",userMax)
                    if userMax == 0 {
                        Config.isUserListOK = true
                    }
                    
                    let cmd = Config.bpProtocol.getAdminPWD()
                    Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                    
                }
                
                break
                
                
            case BPprotocol.cmd_device_name:
                if cmd[1] == BPprotocol.type_write {
                    
                    if cmd[4] == BPprotocol.result_success{
                        
                        print("set device name ok")
                        if !isRestore{
                            
                            deviceNameLabel.text  = tmpDeviceName!
                            
                        }
                        
                        
                    }
                    Config.deviceName =  deviceNameLabel.text!
                }else if cmd[1] == BPprotocol.type_read{
                    var deviceName_Arr = [UInt8]()
                    
                    for j in 4 ... Int(datalen) + 3{
                        if cmd[j] != 0xFF && cmd[j] != 0x00{
                            deviceName_Arr .append(cmd[j])
                        }
                    }
                    
                    let deviceName = String(bytes: deviceName_Arr, encoding: .utf8) ?? "unKnown"
                    deviceNameLabel.text = deviceName
                    Config.deviceName =  deviceNameLabel.text!
                    
                    let cmd = Config.bpProtocol.getDeviceConfig()
                    Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                }
                
                break
                
            case BPprotocol.cmd_user_data:
                
                if cmd[1] == BPprotocol.type_read{
                    if isbackup{
                        if !isCancel {
                            print("user data read")
                            if cmd[4] != 0xFF /*&& cmd[4] != 0x00*/ {
                                
                                for i in 4 ... cmd.count - 1{
                                    Config.userDataArr.append(cmd[i])
                                }
                                
                                print(String(format:"b_cnt=%d\r\n",backupCount))
                                
                                
                                updateBackupDialog()
                                backupCount += 1
                                if backupCount >= backupMax+1{
                                    
                                    isbackup = false
                                    self.downloadFrame.removeFromSuperview();
                                    UserDefaults.standard.set(Config.userDataArr, forKey: Config.User_ListTag_backup)
                                    
                                    UserDefaults.standard.set(true, forKey: Config.backupOK)
                                    
                                }else{
                                    
                                    
                                    let cmd = Config.bpProtocol.getUserData(UserCount: backupCount - 2)
                                    Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                                }
                                
                                
                            }
                        }
                    }
                    
                }else{
                    restoreCount += 1
                    updateRestoreDialog()
                    
                    if restoreCount >= restoreMax {
                        self.downloadFrame.removeFromSuperview();
                        
                        
                    }else{
                        let user_addr = Int((restoreCount - 3/*4*/)) * Int(BPprotocol.userDataSize)
                        //let user_addr = (restoreCount - 3/*4*/) * BPprotocol.userDataSize //
                        print(String(format:"addr=%d\r\n", user_addr))
                        print(String(format:"array cnt=%d\r\n", Config.userDataArr.count))
                        var userData = [UInt8]()
                        for i in 0 ... BPprotocol.userDataSize - 1{
                            
                            userData.append(Config.userDataArr[user_addr+i])
                            
                            print(String(format:"data[%d]=%02X\r\n",i,userData[i]))
                            
                            
                        }
                        let cmd = Config.bpProtocol.setUserData(UserData: userData)
                        Config.bleManager.writeData(cmd:cmd,characteristic: bpChar!)
                    }
                    
                    
                }
                break
                
            case BPprotocol.cmd_set_admin_pwd:
                
                for i in 0 ... cmd.count - 1{
                    print(String(format:"cmd[%d]=%02x",i,cmd[i]))
                }
                if cmd[1] == BPprotocol.type_write{
                    if cmd[4] == BPprotocol.result_success{
                        
                        
                        
                        if isRestore{
                            restoreCount += 1
                            updateRestoreDialog()
                            /*let nameUint8 = Util.StringtoUINT8(data: DeviceData.sharedInstance.deviceName!, len: 16, fillData: BPprotocol.nullData)
                             
                             let cmd = bpProtocol.setDeviceName(deviceName: nameUint8, nameLen: (DeviceData.sharedInstance.deviceName?.characters.count)!)
                             writeData(cmd: cmd, characteristic: bpChar!)*/
                            let cmd = Config.bpProtocol.setEraseUserList()
                            Config.bleManager.writeData(cmd:cmd,characteristic: bpChar!)
                            isErase = true
                            
                        }else{
                            print(tmpAdminPWD)
                            adminPWDLabel.text = tmpAdminPWD
                            
                        }
                    }else {
                        self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_password"))
                        
                    }
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
                    
                    if isbackup {
                        if !isCancel{
                            Config.ADMINPWD = pwd
                            UserDefaults.standard.set(  Config.ADMINPWD, forKey: Config.ADMIN_PWDTag_backup)
                            backupCount += 1
                            Config.userDataArr.removeAll()
                            updateBackupDialog()
                            if backupMax > 2/*3*/ {
                                
                                print(String(format:"backup=%d\r\n",backupCount - 1/*2*/))
                                let cmd = Config.bpProtocol.getUserData(UserCount: backupCount - 1/*2*/)
                                Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                            }
                            else{
                                Config.userDataArr.removeAll()
                                UserDefaults.standard.set(Config.userDataArr, forKey: Config.User_ListTag_backup)
                                
                                
                                UserDefaults.standard.set(true, forKey: Config.backupOK)
                                self.downloadFrame.removeFromSuperview();
                                isbackup = false
                            }
                        }
                    }else{
                        
                        
                        adminPWDLabel.text = pwd
                        
                        //DeviceData.sharedInstance.adminPWD =  newAdminPWD
                        
                        let cmd = Config.bpProtocol.getFW_version()
                        Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
                        
                    }
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
                    
                    
                    SettingsTableViewController.startTimeArr = [Int(UInt16(data[0]) * 256 + UInt16(data[1])), Int(data[2]), Int(data[3]), Int(data[4]), Int(data[5]), Int(data[6])]
                    let calendar = Calendar.current
                    let currentdate = Date()
                    var dateComponents = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from:  currentdate)
                    print(String(format:" text before Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
                    
                    
                    //dateComponents.year = SettingsTableViewController.startTimeArr[0]
                    
                    dateComponents.month = SettingsTableViewController.startTimeArr[1]
                    dateComponents.day = SettingsTableViewController.startTimeArr[2]
                    dateComponents.hour = SettingsTableViewController.startTimeArr[3]
                    dateComponents.minute = SettingsTableViewController.startTimeArr[4]
                    dateComponents.second = SettingsTableViewController.startTimeArr[5]
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd HH:mm"
                    
                    //let currentTime = formatter.string(from: currentdate)
                    deviceTimeLabel.text = String(format:"%04d/%02d/%02d %02d:%02d",dateComponents.year!
                        ,dateComponents.month!
                        ,dateComponents.day!
                        ,dateComponents.hour!
                        ,dateComponents.minute!)
                    //self.dateFormatter.string(from: calendar.date(from: dateComponents)!)
                    
                    
                    //"\(d)-\(m)-\(y) \(hh):\(mm):\(ss)"
                    
                    
                    let cmd = Config.bpProtocol.getDeviceName()
                    //Config.bpProtocol.getDeviceConfig()
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
                        let calendar = Calendar.current
                        let currentdate = Date()
                        var dateComponents = calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from:  currentdate)
                        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
                        print(String(format:" text before Y=%d\r\nM=%d\r\nD=%d\r\nH=%d\r\nm=%d\r\ns=%d\r\n",dateComponents.year!,dateComponents.month!,dateComponents.day!,dateComponents.hour!,dateComponents.minute!,dateComponents.second!))
                        
                        
                        dateComponents.year = SettingsTableViewController.startTimeArr[0]
                        
                        dateComponents.month = SettingsTableViewController.startTimeArr[1]
                        dateComponents.day = SettingsTableViewController.startTimeArr[2]
                        dateComponents.hour = SettingsTableViewController.startTimeArr[3]
                        dateComponents.minute = SettingsTableViewController.startTimeArr[4]
                        dateComponents.second = SettingsTableViewController.startTimeArr[5]
                        
                        deviceTimeLabel.text = self.dateFormatter.string(from: calendar.date(from: dateComponents)!)
                        //deviceTimeLabel.text = timeText
                        //showToastDialog(title:"",message:GetSimpleLocalizedString("program_success"))
                        
                    }/*else{
                     showToastDialog(title:"",message:GetSimpleLocalizedString("program_fail"))
                     }*/
                    
                }
                
                
                break
                
            case BPprotocol.cmd_erase_users:
                restoreCount += 1
                print("restoreCount")
                print("restoreCount= \(restoreCount)")
                updateRestoreDialog()
                
                if restoreMax > 3/*4*/ {
                    let user_addr = Int((restoreCount - 3/*4*/)) * Int(BPprotocol.userDataSize)
                    //let user_addr = (restoreCount - 3/*4*/) * BPprotocol.userDataSize  //
                    
                    
                    let userIndex = Int16((UInt16(Config.userDataArr[user_addr]) << 8 ) | (UInt16(Config.userDataArr[user_addr+1]) & 0x00FF))
                    var userData = [UInt8]()
                    for i in 0 ... BPprotocol.userDataSize - 1{
                        
                        userData.append(Config.userDataArr[user_addr+i])
                        
                        
                    }
                    let cmd = Config.bpProtocol.setUserData( UserData: userData)
                    Config.bleManager.writeData(cmd:cmd,characteristic: bpChar!)
                }else{
                    self.downloadFrame.removeFromSuperview();
                    
                    
                }
                break
                
                
            default:
                break
                
            }
        }
        
    }
    func showProgressDialog(Title:String, Message:String, countMax:Int16) {
        
        
        //Set Initial Value
        label_progress_dg_title.text = Title
        label_progress_dg_msg.text = Message
        downloadFrame.frame = CGRect(origin: CGPoint(x:0 ,y:0), size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        
        downloadView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        
        UIApplication.shared.keyWindow?.addSubview(self.downloadFrame);
        
        pg_bar_progress_dg_view.progress = 0.0
        pg_bar_progress_dg_view.setProgress(0, animated: true)
        label_progress_dg_percent.text = "0%"
        label_progress_dg_count.text = "\(0) / \(countMax)"
        
        isCancel = false
        
    }
    
    
    func showMessageDialog(Title:String, Message:String) {
        
        
        //Set Initial Value
        label_msg_dg_title.text = Title
        label_msg_dg_msg.text = Message
        msgFrame.frame = CGRect(origin: CGPoint(x:0 ,y:0), size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        
        msgView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        
        UIApplication.shared.keyWindow?.addSubview(self.msgFrame);
        
        
    }
    
    func updateBackupDialog(){
        
        let progressValue: Float = Float(backupCount) / Float(backupMax)
        let prog_percent: Int = Int(progressValue * 100)
        
        print(prog_percent)
        
        //Update Info
        pg_bar_progress_dg_view.setProgress(progressValue, animated: true)
        label_progress_dg_percent.text = "\(prog_percent)%"
        label_progress_dg_count.text = "\(backupCount) / \(backupMax)"
        
        
        if backupCount >= backupMax{
            
            delayOnMainQueue(delay: 0) {
                self.showMessageDialog(Title: self.GetSimpleLocalizedString("backup_status"), Message:self.GetSimpleLocalizedString("backup_completed"))
                
            }
        }
        
    }
    
    func updateRestoreDialog(){
        let progressValue: Float = Float(restoreCount) / Float(restoreMax)
        let prog_percent: Int = Int(progressValue * 100)
        
        print(prog_percent)
        
        //Update Info
        pg_bar_progress_dg_view.setProgress(progressValue, animated: true)
        label_progress_dg_percent.text = "\(prog_percent)%"
        label_progress_dg_count.text = "\(restoreCount) / \(restoreMax)"
        
        if restoreCount >= restoreMax{
            print(Config.deviceName)
            let nameUint8 = Util.StringtoUINT8(data: Config.deviceName , len: 16, fillData: BPprotocol.nullData)
            
            let cmd = Config.bpProtocol.setDeviceName(deviceName: nameUint8, nameLen: (Config.deviceName.utf8.count))
            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
            
            delayOnMainQueue(delay: 0) {
                
                self.showMessageDialog(Title: self.GetSimpleLocalizedString("restore_status"), Message:self.GetSimpleLocalizedString("restore_completed"))
                
            }
        }
        
        
        
    }
    @objc func connectTimeOutTask(){
        print("connect time out");
        Config.bleManager.disconnect()
        connectTimer = nil
        backToMainPage()
        
    }
    
    func StartConnectTimer(){
        if connectTimer == nil {
            
            connectTimer = Timer.scheduledTimer(timeInterval: Config.ConTimeOut, target: self, selector: #selector(connectTimeOutTask), userInfo: nil, repeats: false)
            
            
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
    
    
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("TTTTTTTTTT")
        self.setcurrentdate()
    }
    
    
    
    
    @objc func showMasterFAQ() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "MasterFAQ") as! MasterFAQ
        vc.mydelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    func setcurrentdate(){
        let calendar = Calendar.current
        let dateComponents =  calendar.dateComponents([.year,.month, .day, .hour,.minute,.second], from: Date())
        
        SettingsTableViewController.startTimeArr[0] = dateComponents.year!
        SettingsTableViewController.startTimeArr[1] = dateComponents.month!
        SettingsTableViewController.startTimeArr[2] = dateComponents.day!
        SettingsTableViewController.startTimeArr[3] = dateComponents.hour!
        SettingsTableViewController.startTimeArr[4] = dateComponents.minute!
        SettingsTableViewController.startTimeArr[5] = dateComponents.second!
        
        let timeUInt8 = Util.toUInt8date(SettingsTableViewController.startTimeArr)
        let cmd = Config.bpProtocol.setDeviceTime(deviceTime: timeUInt8)
        Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
        
        self.tmpDeviceTime = cmd
    }
    
    
}

