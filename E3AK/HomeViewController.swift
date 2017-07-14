//
//  HomeViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/7.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreBluetooth
import UIAlertController_Blocks
import CoreMotion

enum DeviceSearchingStatus {
    case DeviceSearching
    case DeviceNotFound
    case DeviceFound
}


class HomeViewController: BLE_ViewController{

    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var doorCheckButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceTypeLabel: UILabel!
    @IBOutlet weak var doorButton: UIButton!
    @IBOutlet weak var openDoorButton: UIButton!
    @IBOutlet weak var doorStatusLabel: UILabel!
    @IBOutlet weak var dotImageView: UIImageView!
    @IBOutlet weak var loadingImageView: UIImageView!
    
    @IBOutlet weak var enrollButon: UIButton!
    var doorIsOpen = false
    var isAutoMode = false
    var deviceFoundStatus: DeviceSearchingStatus = .DeviceFound
    var deviceInfoList: [DeviceInfo] = [];
    var selectDeviceIndex:Int = 0
    var isAdminEnroll:Bool = false
    var isEnroll:Bool = false
    var isOpenDoor:Bool = false
    var isKeepOpen:Bool = false
    var userEnrollData: Data!
    var adminEnrollData: Data!
    var disTimer:Timer? = nil
    let motionManager = CMMotionManager()
    var shakeTime = 0
     var bgAutoTimer = Timer()
    var scanningTimer = Timer();
    var connectTimer:Timer? = nil

    var isBackground = false
    
    var bgTaskID: UIBackgroundTaskIdentifier?
    var backCount = 0
    
    var backgroundTimers: [Timer] = []
    var isForce:Bool = false
    var ScanningTimerflag = false
    var bgAutoTimerFlag = false
    var isMotion = false
    var selectSetDevice:CBPeripheral!
    var forceDevice:CBPeripheral!
    @IBAction func didEnroll(_ sender: Any) {
        if !isAutoMode {
         StopScanningTimer()
        if deviceInfoList.count > 0 {
            let target = GetTargetDevice()
        self.loginAlert(title:self.GetSimpleLocalizedString("enroll_dialog_title") , subTitle: "", placeHolder1: self.GetSimpleLocalizedString("Please Provide Up to 16 characters"), placeHolder2: self.GetSimpleLocalizedString("4~8 digits"), keyboard1: .default, keyboard2: .numberPad, handler: { (input1, input2) in
            
           // print("user input2: \(input1) & \(input2)")
            let userID:[UInt8] = Util.StringtoUINT8(data: input1!, len: BPprotocol.userID_maxLen, fillData: BPprotocol.nullData)
            let userPWD:[UInt8] = Util.StringtoUINT8(data: input2!, len: BPprotocol.userPD_maxLen, fillData: BPprotocol.nullData)
            if !input1!.isEmpty {
                self.isEnroll = true
               // print(input1);
                if input1! == Config.AdminID{
                    //print("admin enroll");
                    self.adminEnrollData = Config.bpProtocol.setAdminEnroll(UserID: userID,Password: userPWD)
                    self.isAdminEnroll = true
                    
                }
                else{
                    self.userEnrollData = Config.bpProtocol.setUserEnroll(UserID: userID, Password: userPWD)
                    //print("user enroll");
                }
               
                Config.bleManager.connect(bleDevice: target)
                self.StartConnectTimer()
            }
            
        })
        }else{
            StartScanningTimer()
            showToastDialog(title:"",message:GetSimpleLocalizedString("Can't find device"));
            }
            
        }else{
          
          showToastDialog(title:"",message:GetSimpleLocalizedString("AUTO_ENABLE_CONFLICT" ));
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       settingsButton.setTitle(GetSimpleLocalizedString("Settings"),for: .normal)
        doorCheckButton.setTitle(GetSimpleLocalizedString("Auto"),for: .normal)
        enrollButon.setTitle(GetSimpleLocalizedString("Enroll"), for: .normal)
        
        gradientView.gradientBackground(percent: 250/667)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapChooseDevice))
        deviceNameLabel.addGestureRecognizer(gestureRecognizer)
        openDoorButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
        openDoorButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        settingsButton.adjustButtonEdgeInsets()
         Config.bleManager.Init(delegate: self)
        
        deviceFoundStatus = .DeviceNotFound
        changeViewContentSettings()
        deviceNameLabel.text = ""
        deviceTypeLabel.text = ""
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        deviceFoundStatus = .DeviceSearching
        changeViewContentSettings()
        
        //Config.bleManager.ScanBLE()
        StartScanningTimer()
        
        if motionManager.isDeviceMotionAvailable{
            motionManager.deviceMotionUpdateInterval = 0.02
            motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { (data, error) in
                if let acc = data?.userAcceleration.z{
                    if acc > 0.5{
                        self.shakeTime += 1
                        print("ShakeTIme: \(self.shakeTime)")
                       
                        self.delayOnMainQueue(delay: 1, closure: {
                            self.shakeTime = 0
                        })
                        
                        if self.isAutoMode {
                        
                            if !self.isOpenDoor {
                            print("open door in auto mode")
                            self.isMotion  =  true
                        }
                        if self.bgAutoTimer.isValid{
                            //print("bg alive")
                            
                        }else if self.isBackground{
                            self.StartBgAutoTimer()
                            }
                        }
                        
                        //if self.shakeTime == 3{
                        //self.openTheDoor(true)
                        //}
                    }
                }
            })
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBG), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterFG), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
       
    }
    
    public override func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if ( central.state == .poweredOn ) {
            Config.bleManager.ScanBLE()
        } else if ( central.state == .poweredOff ) {
            
            //Open BlueTooth Setting
            openBlueTooth_Setting();
        }
        
        
    }
    
    public override func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        
    }

    public override func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name: String = advertisementData["kCBAdvDataLocalName"] as! String
        let uuid: UUID = peripheral.identifier
        
         let expect_level: Int = readExpectLevelFromDbByUUID(uuid.uuidString);
        
        print("deviceName = \(name)")
        
        if((RSSI.intValue <= 0) && (RSSI.intValue >= Config.BLE_RSSI_MIN)) {
            
            var tmp: DeviceInfo = DeviceInfo(UUID: uuid, name: name, peripheral: peripheral, rssi: RSSI.intValue, current_level: Convert_RSSI_to_LEVEL(RSSI.intValue), expect_level: 0, alive: 3)
            
            if( deviceInfoList.contains(tmp)) {
                
                let du_idx:Int = deviceInfoList.index(of: tmp)!
                
                //print("UUID Dulicate!! Index = \(du_idx)")
                
                //AVG RSSI
                let avg_rssi: Int = (RSSI.intValue + deviceInfoList[du_idx].rssi) / 2;
                tmp.rssi = avg_rssi;
                tmp.current_level = Convert_RSSI_to_LEVEL(avg_rssi)
                
            //    print("RSSI: \(RSSI.intValue), LEVEL: \(tmp.current_level)")
                
                deviceInfoList[du_idx] = tmp;
            }
            else {
                deviceInfoList.append(tmp)
                deviceNameLabel.text = deviceInfoList[0].name
                
                //Save to DB
                saveExpectLevelToDbByUUID(uuid.uuidString, expect_level)
            }
            if deviceInfoList.count > 0 {
            deviceFoundStatus = .DeviceFound
                changeViewContentSettings()
            }
        }
        
        
        deviceInfoList.sort();
        
        
    }

  
    func didEnterBG(){
        
        print("didEnterBG")
        
        isBackground = true
        
        //Stop Timer
        StopScanningTimer()
        
        if(isAutoMode) {
            
            //MARK: beginBackgroundTask
            print("Request BackgroundTask !!")
            
            bgTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                self.backCount = 0
                
               
                self.motionManager.deviceMotionUpdateInterval = 0.02
                self.motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: { (data, error) in
                    if let acc = data?.userAcceleration.z{
                        if acc > 0.5{
                            self.shakeTime += 1
                            print("ShakeTIme: \(self.shakeTime)")
                            
                            self.delayOnMainQueue(delay: 1, closure: {
                                self.shakeTime = 0
                            })
                            
                            if self.isAutoMode {
                                
                                if !self.isOpenDoor {
                                    print("open door in auto mode")
                                    self.isMotion  =  true
                                }
                                if self.bgAutoTimer.isValid{
                                    //print("bg alive")
                                    
                                }else if self.isBackground{
                                    self.StartBgAutoTimer()
                                }
                            }
                            
                            //if self.shakeTime == 3{
                            //self.openTheDoor(true)
                            //}
                        }
                    }
                })
                //MARK: NEED TODO
                //self.act(.expire)
               // UIApplication.shared.endBackgroundTask(self.bgTaskID!)
            })
            
            //Start Timer
            StartBgAutoTimer();
            
        }
        
    }
    
    func didEnterFG(){
        
        print("didEnterFG")
        
        isBackground = false
        //Start Timer
        StartScanningTimer();
        
        guard isAutoMode else{ return }
        for timer in backgroundTimers{
            timer.invalidate()
        }
        backgroundTimers = []
        
        //Stop Timer
        bgAutoTimer.invalidate()
       
    }
    
    func didTapChooseDevice() {
        StopScanningTimer()
        var deviceList:[String] = []
        var deviceOBJ:[CBPeripheral] = []
        
        for i in 0 ... deviceList.count{
            deviceOBJ.append(deviceInfoList[i].peripheral)
            deviceList.append(deviceInfoList[i].name)
        }
        
        UIAlertController.showActionSheet(
            in: self,
            withTitle: self.GetSimpleLocalizedString("Please Choose"),
            message: nil,
            cancelButtonTitle: self.GetSimpleLocalizedString("Cancel"),
            destructiveButtonTitle: nil,
            otherButtonTitles: deviceList, popoverPresentationControllerBlock: nil) { (controller, action, buttonIndex) in
                
            if (buttonIndex == controller.cancelButtonIndex)
            {
                print("Cancel Tapped")
            }
            else if (buttonIndex == controller.destructiveButtonIndex)
            {
                print("Delete Tapped")
            }
            else if (buttonIndex >= controller.firstOtherButtonIndex)
            {
                print("Other Button Index \(buttonIndex - controller.firstOtherButtonIndex)")
                if self.deviceInfoList.count > 0{
                    if self.selectDeviceIndex == (buttonIndex - controller.firstOtherButtonIndex) && self.isForce{
                        self.selectDeviceIndex = 0
                        self.deviceNameLabel.text = self.deviceInfoList[0].name
                        self.deviceNameLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                        self.isForce = false
                    }else{
                

                    self.deviceNameLabel.text = deviceList[buttonIndex - controller.firstOtherButtonIndex]
                        self.selectDeviceIndex = (buttonIndex - controller.firstOtherButtonIndex)
                        
                        self.isForce = self.isExistTarget(targetUUID: deviceOBJ[self.selectDeviceIndex].identifier.uuidString)
                        
                        if self.isForce {
                            self.forceDevice = deviceOBJ[self.selectDeviceIndex]
                            self.deviceNameLabel.textColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
                        }
                        
                    }
                    self.StartScanningTimer()
                }
            }
        }
    }
    
    @IBAction func didTapOpenDoor(_ sender: Any) {
        
        if !isAutoMode {
        StopScanningTimer()
        if deviceInfoList.count > 0 {
        isOpenDoor = true
        let target = GetTargetDevice()
        
            
        let isAdmin = Config.saveParam.bool(forKey: (target.identifier.uuidString))
        if isAdmin || checkConTimeLimit(target: target)
        {
            Config.bleManager.connect(bleDevice: target)
            StartConnectTimer()
        }
            
        switch deviceFoundStatus
        {
        case .DeviceNotFound:
            deviceFoundStatus = .DeviceSearching
            changeViewContentSettings()
        
        case .DeviceFound:
            
            openDoorButton.setTitle("", for: .normal)
            openDoorButton.setImage(R.image.tickWhite(), for: .normal)
            doorButton.setBackgroundImage(R.image.doorOpen(), for: .normal)
            doorStatusLabel.text = "DOOR OPENED"
            doorStatusLabel.textColor = HexColor("00b900")
            openDoorButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
            openDoorButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
            
        default:
            break
        }
        }else{
            showToastDialog(title:"",message:GetSimpleLocalizedString("Can't find device"));
            StartScanningTimer()
            }
        }else{
            showToastDialog(title:"",message:GetSimpleLocalizedString("AUTO_ENABLE_CONFLICT" ));
            
        }

        
    }
    
    @IBAction func didTapDoorCheck(_ sender: Any) {
        isAutoMode = !isAutoMode
        if isAutoMode{
            doorCheckButton.setImage(R.image.checkboxTick(), for: .normal)
        }else{
           doorCheckButton.setImage(R.image.checkboxNone(), for: .normal)
        
        }
        print("didTapDoorCheck")
    }
    
    
    func changeViewContentSettings() {
         deviceTypeLabel.isHidden = true
        switch deviceFoundStatus
        {
        
        case .DeviceSearching:
        
            deviceNameLabel.text = GetSimpleLocalizedString("Searching…")
            deviceNameLabel.isUserInteractionEnabled = false
            deviceTypeLabel.text = GetSimpleLocalizedString("Please wait a moment…")
            deviceTypeLabel.isHidden = true
            dotImageView.isHidden = true
            openDoorButton.setTitle("", for: .normal)
            openDoorButton.setImage(nil, for: .normal)
            openDoorButton.setBackgroundImage(R.image.btnGray(), for: .normal)
            openDoorButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
            openDoorButton.isUserInteractionEnabled = false
            doorButton.setBackgroundImage(R.image.doorClose(), for: .normal)
            doorButton.isUserInteractionEnabled = false
            doorStatusLabel.text = "DOOR CLOSED"
            doorStatusLabel.textColor = HexColor("a4aab3")
            loadingImageView.isHidden = false
            loadingImageView.rotate360Degree()

        case .DeviceNotFound:
            
            deviceNameLabel.text = "目前找不到裝置"
            deviceNameLabel.isUserInteractionEnabled = false
            deviceTypeLabel.text = "請稍後再試"
            dotImageView.isHidden = true
            openDoorButton.setTitle("", for: .normal)
            openDoorButton.setImage(R.image.researchWhite(), for: .normal)
            openDoorButton.setBackgroundImage(R.image.btnGray(), for: .normal)
            openDoorButton.setShadowWithColor(color: HexColor("a4aab3"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
            openDoorButton.isUserInteractionEnabled = true
            doorButton.setBackgroundImage(R.image.doorClose(), for: .normal)
            doorButton.isUserInteractionEnabled = false
            doorStatusLabel.text = "DOOR CLOSED"
            doorStatusLabel.textColor = HexColor("a4aab3")
            loadingImageView.isHidden = true
            loadingImageView.stopRotate()
            
        case .DeviceFound:
            
            //deviceNameLabel.text = "E3AK001"
            deviceNameLabel.isUserInteractionEnabled = true
            //deviceTypeLabel.text = "型號ABC123"
            dotImageView.isHidden = false
            openDoorButton.setTitle("OPEN", for: .normal)
            openDoorButton.setImage(nil, for: .normal)
            openDoorButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
            openDoorButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
            openDoorButton.isUserInteractionEnabled = true
            doorButton.setBackgroundImage(R.image.doorClose(), for: .normal)
            doorButton.isUserInteractionEnabled = true
            doorStatusLabel.text = "DOOR CLOSED"
            doorStatusLabel.textColor = HexColor("a4aab3")
            loadingImageView.isHidden = true
            loadingImageView.stopRotate()
        }
    }
    
    
    
    @IBAction func LongPress(_ sender: Any) {
        if !isAutoMode{
        StopScanningTimer()
        if deviceInfoList.count > 0 {
           
            let target = GetTargetDevice()
            
            
            let isAdmin = Config.saveParam.bool(forKey: (target.identifier.uuidString))
            if isAdmin
            {   if !isKeepOpen{
                isKeepOpen = true
                Config.bleManager.connect(bleDevice: target)
                StartConnectTimer()
                }
            }
        }else{
            StartScanningTimer()
            showToastDialog(title:"",message:GetSimpleLocalizedString("Can't find device"));
        }
        }else{
            showToastDialog(title:"",message:GetSimpleLocalizedString("AUTO_ENABLE_CONFLICT" ));
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       
        
        if (segue.identifier == "showSettingsTableViewController") {
            let nvc = segue.destination  as! 
            SettingsTableViewController
            ///let vc = nvc.topViewController as! Intro_PasswordViewController
          
            nvc.selectedDevice = selectSetDevice
            
            }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
       
      
        StopScanningTimer()
        if(isAutoMode){
            print("Need Disable 'AUTO-MODE' First!!")
            showToastDialog(title:"",message:GetSimpleLocalizedString("AUTO_ENABLE_CONFLICT" ));
            
            return false;
        }
        
        
        if deviceInfoList.count > 0{
            selectSetDevice = GetTargetDevice()
            
        
        let isAdmin = Config.saveParam.bool(forKey: ( selectSetDevice.identifier.uuidString))
    
           
            if isAdmin
            {
                return true
            }else{
              
                let vc = UserProximityReadRangeViewController(nib:R.nib.userProximityReadRangeViewController)
               
                vc.selectedDevice = GetTargetDevice()
                vc.current_level_RSSI = GetCurrLevel(targetUUID: selectSetDevice.identifier.uuidString)
                
                navigationController?.isNavigationBarHidden = false
                navigationController?.pushViewController(vc, animated: true)
                return false
                 }
            
        }else{
            
            showToastDialog(title:"",message:GetSimpleLocalizedString("Can't find device"));
            StartScanningTimer()
            

          return  false
        }
        
        return true
    }

    public override func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
       super.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: error)
        selectSetDevice = peripheral
        connectTimer?.invalidate()
        connectTimer = nil
        if isEnroll{
            if isAdminEnroll {
               Config.bleManager.writeData(cmd: adminEnrollData, characteristic: bpChar)
            }else{
               Config.bleManager.writeData(cmd: userEnrollData, characteristic: bpChar)
            }
        
        }else if isOpenDoor {
            let isAdmin = Config.saveParam.bool(forKey: (selectSetDevice.identifier.uuidString))
            var cmd = Data()
            if isAdmin {
            cmd = Config.bpProtocol.setAdminIndentify()
               
            }else{
                let userIndex = Config.saveParam.integer(forKey: Config.userIndexTag)
                cmd = Config.bpProtocol.setUserIndentify(UserIndex: userIndex)

            }
             Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
        
        }else if isKeepOpen {
          let cmd = Config.bpProtocol.getDeviceConfig()
            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
        }
        
       
        isOpenDoor = false
        isAdminEnroll = false
        isEnroll = false
        
        if disTimer == nil {
            
            disTimer = Timer.scheduledTimer(timeInterval: Config.disConTimeOut, target: self, selector: #selector(disconnectTask), userInfo: nil, repeats: false)
            
            
        }

    }

    override func cmdAnalysis(cmd:[UInt8]){
        let datalen = Int16( UInt16(cmd[2]) << 8 | UInt16(cmd[3] & 0x00FF))
        /* for i in 0 ... cmd.count - 1{
         print(String(format:"r-cmd[%d]=%02x\r\n",i,cmd[i]))
         }*/
        if datalen == Int16(cmd.count - 4) {
            switch cmd[0]{
                
            case BPprotocol.cmd_admin_enroll:
                var isAdmin = false
                if cmd[4] == BPprotocol.result_success {
                    isAdmin = true
                }else{
                    isAdmin = false
                }
                Config.saveParam.set(isAdmin, forKey:
                    selectSetDevice.identifier.uuidString)
                
                //self.backToMainPage()
                break
                
            case BPprotocol.cmd_user_enroll:
                
                if datalen > 1 {
                    let userIndex:Int = Int(UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF))
                    
                    print("userIndex=\(userIndex)")
                    Config.saveParam.set(userIndex, forKey: selectSetDevice.identifier.uuidString + Config.userIndexTag)
                    Config.saveParam.set(false, forKey: selectSetDevice.identifier.uuidString)
                    
                }
                
                break
            case BPprotocol.cmd_device_config:
                var cmdData = Data()
                for i in 0 ... cmd.count - 5{
                  cmdData.append(cmd[i+4])
                }
                if cmd[1] == BPprotocol.type_read{
                    if cmd[5] == BPprotocol.door_status_KeepOpen {
                        print("keepOpen\r\n")
                        cmdData[1] = UInt8(BPprotocol.door_status_delayTime)
                        
                    }else {
                       cmdData[1] = UInt8(BPprotocol.door_status_KeepOpen)
                        print("delay\r\n")
                    }
                    
                    for j in 0 ... cmd.count - 1 {
                        
                        print(String(format:"%02X",cmd[j]))
                    }
                    
                    
                    
                    let newCmd = Config.bpProtocol.setDeviceConfig(door_option: cmdData[0], lockType: cmdData[1], delayTime: Int16(UInt16(cmdData[2]) * 256 + UInt16(cmdData[3])), G_sensor_option: cmdData[4])
                        Config.bleManager.writeData(cmd: newCmd, characteristic: bpChar)
                    
                }else if cmd[1] == BPprotocol.type_write{
                    isKeepOpen = false

                }
                break
                
            case BPprotocol.cmd_fw_version:
                if cmd[1] == BPprotocol.type_read{
                    
                    var data = [UInt8]()
                    for i in 4 ... cmd.count - 1{
                        data.append(cmd[i])
                    }
                    let major = data[0]
                    let minor = data[1]
                    
                    if major == 1 && minor >= 6{
                        Config.bleManager.disconnectByCMD(char: bpChar)
                        
                    }
                    else{
                        Config.bleManager.disconnect()
                        
                    }
                    if isAutoMode{
                      // Config.bleManager.release()
                    }else{
                     StartScanningTimer()
                    }
                    //isMotion = false
                    //self.backToMainPage()
                }
                
                break
            default:
                break
                
            }

        }
        
    }
    
    func disconnect() {
        
       
        //peripheral.delegate = nil
        //self.peripheral = nil
        
        let cmd = Config.bpProtocol.getFW_version()
        Config.bleManager.writeData(cmd: cmd, characteristic: bpChar)
       
    }

    func disconnectTask(){
         isKeepOpen = false
        print("disconnect time out");
        disconnect()
        
        disTimer = nil
    }
    func connectTimeOutTask(){
        isKeepOpen = false
        isOpenDoor = false
        isEnroll = false
        
        print("connect time out");
        Config.bleManager.disconnect()
        connectTimer = nil
        deviceFoundStatus = .DeviceSearching
        changeViewContentSettings()
        StartScanningTimer()
    }

    func GetTargetDevice()->CBPeripheral{
        var targetDevice:CBPeripheral?
        
        if isForce{
            if selectDeviceIndex < deviceInfoList.count{
                if isExistTarget(targetUUID: forceDevice.identifier.uuidString){
                    targetDevice = forceDevice
                }
            }else{
               targetDevice = deviceInfoList[selectDeviceIndex].peripheral
            }
        }else{
            
            var current_level = deviceInfoList[0].current_level
             targetDevice = deviceInfoList[0].peripheral
            for i in 0 ... deviceInfoList.count - 1{
                if deviceInfoList[i].current_level < current_level{
                    
                    targetDevice = deviceInfoList[i].peripheral
                    current_level = deviceInfoList[i].current_level
                }
            }
        }
    
      return targetDevice!
    }
    
    func StartBgAutoTimer() {
        
        //Create Timer
        bgAutoTimerFlag = true
        bgAutoTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateBgAutoTimer), userInfo: nil, repeats: true)
    }
    func StopBgAutoTimer(){
        bgAutoTimerFlag = false
        bgAutoTimer.invalidate()
    }
    
    func updateBgAutoTimer() {
        //
        // print("updateBgAutoTimer()")
    if bgAutoTimerFlag {
       
        
        
        
        if(isAutoMode && !isOpenDoor) {
            // print(" ---- isBackGround-AutoMode ---- ")
            if !Config.bleManager.isScanBLE(){
               Config.bleManager.ScanBLE()
            }
            
            checkDeviceAlive()
            
            if isMotion{
                
        
                Config.bleManager.ScanBLEStop()

                
            if deviceInfoList.count > 0 {
            
                let target = GetTargetDevice()
                
                isMotion = false
                let expectLEVEL = readExpectLevelFromDbByUUID(target.identifier.uuidString)
                print("expectLEVEL=: \(expectLEVEL )")

                if expectLEVEL >= GetCurrLevel(targetUUID: target.identifier.uuidString){
                    Config.bleManager.connect(bleDevice: target)
                    
                    isOpenDoor = true

                  }
                }
            }
            print("Scan-CNT: \(deviceInfoList.count)")
             //StopBgAutoTimer()
        }
       
        /*for (item) in deviceInfoList {
         print("BG-AutoMode Items: \(item)")
         
         let curr_ticks: TimeInterval = Date().timeIntervalSince1970
         }*/
        //Get Data from DB
        /*let isUsed: Bool = storeInfo.bool(forKey: (item.UUID.uuidString + expectLevel_isUsed_Suffix))
         let expect_level: Int? = storeInfo.integer(forKey: (item.UUID.uuidString + expectLevel_Value_Suffix))
         let last_ticks: TimeInterval? = storeInfo.object(forKey: (item.UUID.uuidString + device_LastIdentify_Ticks_Suffix)) as? TimeInterval ?? 0
         
         let diff_ticks:Int = Int(curr_ticks - last_ticks!)
         
         print("(\(idx)) name: \(item.name), isUsed = \(isUsed), curr = \(item.current_level), expect = \(String(describing: expect_level)), last_ticks = \(String(describing: last_ticks)), diff = \(diff_ticks)")
         */
        //if((diff_ticks >= 6) && (item.current_level <= expect_level!)) {
        //if((diff_ticks >= 6)) {
        //   autoMode_SelectedDeviceInfo = item
        
        //Assign Device
        /// target_SelectedDeviceInfo = autoMode_SelectedDeviceInfo;
        
        //act(.open)
        // act(.bgAuto)
        
        //    print("Do BG-Auto Open: [\(item.name)] ")
        
        //  break;
        // }
        
        // idx += 1
        // }
        
        // }
        }
    }

    func isExistTarget(targetUUID:String)->Bool{
        
        
        if deviceInfoList.count > 0{
        for i in 0 ... deviceInfoList.count - 1{
            if deviceInfoList[i].UUID.uuidString == targetUUID{
               return true
              }
            }
        }
        
        return false
    }
    
    func StartScanningTimer() {
        //Create Timer
        ScanningTimerflag = true
        scanningTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateScanningTimer), userInfo: nil, repeats: true)
    }
    func StopScanningTimer(){
       ScanningTimerflag = false
       Config.bleManager.ScanBLEStop()
       scanningTimer.invalidate()
       
        
    }
    func GetCurrLevel(targetUUID:String)->Int{
      
        
        if deviceInfoList.count > 0{
            for i in 0 ... deviceInfoList.count - 1{
                if deviceInfoList[i].UUID.uuidString == targetUUID{
                    return deviceInfoList[i].current_level
                    
                }
            }
        }
      return 0
    }
    func checkDeviceAlive(){
    
        var need_remove_array: [Int] = []
        var need_Check_Alive: Bool = true;
        
        if(Config.bleManager.isScanBLE()) {
            need_Check_Alive = true;
        }
        else {
            need_Check_Alive = false;
            
            Config.bleManager.ScanBLE()
        }
        
        //print("Update - Timer")
        
        if( need_Check_Alive) {
            
            for index in 0..<deviceInfoList.count  {
                deviceInfoList[index].alive -= 1;
               
                if(deviceInfoList[index].alive <= 0) {
                    //print("Remove [\(deviceInfoList[index].name)]")
                    
                    need_remove_array.append(index)
                }
            }
            
            for remove_idx in 0..<need_remove_array.count {
                let remove_idx: Int = need_remove_array[remove_idx];
                
                //print("remove idx \(remove_idx)")
                if deviceInfoList.count > remove_idx {
                    deviceInfoList.remove(at: remove_idx)
                }
            }
        }
    
        print(String(format:"check alive device cnt=%d",deviceInfoList.count))
    
    }
    
    func updateScanningTimer() {
        if ScanningTimerflag{
            //Config.bleManager.ScanBLE()
            checkDeviceAlive()
            if !(deviceInfoList.count > 0) {
                deviceFoundStatus = .DeviceSearching
                changeViewContentSettings()
                
            }
        }
       /* //Check isAutoMode
        if(isAutoMode) {
            print(" ---- isAutoMode ---- ")
            var idx: Int = 0;
            
            //Check Need Count
            if(needAutoModeIdentifyCnt == 0) {
                
                for (item) in deviceInfoList {
                    //print("AutoMode Items: \(item)")
                    
                    let curr_ticks: TimeInterval = Date().timeIntervalSince1970
                    
                    //Get Data from DB
                    let isUsed: Bool = storeInfo.bool(forKey: (item.UUID.uuidString + expectLevel_isUsed_Suffix))
                    let expect_level: Int? = storeInfo.integer(forKey: (item.UUID.uuidString + expectLevel_Value_Suffix))
                    let last_ticks: TimeInterval? = storeInfo.object(forKey: (item.UUID.uuidString + device_LastIdentify_Ticks_Suffix)) as? TimeInterval ?? 0
                    
                    let diff_ticks:Int = Int(curr_ticks - last_ticks!)
                    
                    print("(\(idx)) name: \(item.name), isUsed = \(isUsed), curr = \(item.current_level), expect = \(String(describing: expect_level)), last_ticks = \(String(describing: last_ticks)), diff = \(diff_ticks)")
                    
                    if((diff_ticks >= 6) && (item.current_level <= expect_level!)) {
                        //autoMode_SelectedDeviceInfo = item
                        
                        //act(.open)
                        if(!isBackground) {
                            act(.open)
                        }
                        else {
                            if(item.peripheral.state == .connected) {
                                do_Direct_Open();
                            }
                            else if(item.peripheral.state == .connecting) {
                                print(".connecting")
                                
                            }
                        }
                        
                        print("Do Auto Open: [\(item.name)] ")
                        
                        needAutoModeIdentifyCnt += 1;
                        
                        break;
                    }
                    
                    idx += 1
                }
            }
            else {
                print("needAutoModeIdentifyCnt = \(needAutoModeIdentifyCnt)")
                act(.open)
            }
            
            if(isAutoModeIdentidfyDone) {
                needAutoModeIdentifyCnt = 0;
                isAutoModeIdentidfyDone = false
            }
        }
        
        //Update Device Name
        update_target_and_device_name(false)*/
    }

    func checkConTimeLimit(target:CBPeripheral)->Bool{
        var res:Bool = false
        let date = Date()
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        let sec = calendar.component(.second, from: date)
        let currentTime = (minutes * 60) + sec
        let disConTime = Config.saveParam.integer(forKey: (target.identifier.uuidString)+"d_time")
        print("disT=\(disConTime), currT=\(currentTime)")
        if ((abs(currentTime - disConTime)) > Int(Config.disConTimeOut)){
            res = true
        }
        
        return res
    }
    
    func StartConnectTimer(){
        if connectTimer == nil {
            
            connectTimer = Timer.scheduledTimer(timeInterval: Config.ConTimeOut, target: self, selector: #selector(connectTimeOutTask), userInfo: nil, repeats: false)
            
            
        }

    }
    
}
