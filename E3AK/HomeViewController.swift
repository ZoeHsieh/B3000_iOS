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
    var isBackground = false
    
    var bgTaskID: UIBackgroundTaskIdentifier?
    var backCount = 0
    
    var backgroundTimers: [Timer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        Config.bleManager.ScanBLE()
        
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
                        Config.bleManager.ScanBLE()

                        
                        if self.bgAutoTimer.isValid{
                            //print("bg alive")
                            
                        }else if self.isBackground{
                            self.StartBgAutoTimer()
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

    public override func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let name: String = advertisementData["kCBAdvDataLocalName"] as! String
        let uuid: UUID = peripheral.identifier
        
         let expect_level: Int = readExpectLevelFromDbByUUID(uuid.uuidString);
        
        //print("expect_level = \(expect_level)")
        
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

    func StartBgAutoTimer() {
        
        //Create Timer
        bgAutoTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(updateBgAutoTimer), userInfo: nil, repeats: true)
    }
    func didEnterBG(){
        
        print("didEnterBG")
        
        isBackground = true
        
        //Stop Timer
       // scanningTimer.invalidate()
        
        if(isAutoMode) {
            
            //MARK: beginBackgroundTask
            print("Request BackgroundTask !!")
            
            bgTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                self.backCount = 0
                
                Config.bleManager.ScanBLE()
                
                //MARK: NEED TODO
                //self.act(.expire)
                UIApplication.shared.endBackgroundTask(self.bgTaskID!)
            })
            
            //Start Timer
            StartBgAutoTimer();
            
        }
        
        
        
        
        
        
        /*
         guard isAuto else{ return }
         for name in enrolledDevices{
         if scanningDeviceInfoList[name] != nil{
         let timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(bgAuto), userInfo: nil, repeats: true)
         backgroungDevice.append(name)
         backgroundTimers.append(timer)
         }
         }
         */
    }
    
    func didEnterFG(){
        
        print("didEnterFG")
        
        isBackground = false
         Config.bleManager.ScanBLE()
        //Start Timer
        // StartScanningTimer();
        
        guard isAutoMode else{ return }
        for timer in backgroundTimers{
            timer.invalidate()
        }
        backgroundTimers = []
        Config.bleManager.ScanBLE()
        
        //Stop Timer
        bgAutoTimer.invalidate()
    }
    

    func updateBgAutoTimer() {
        
        // print("updateBgAutoTimer()")
        Config.bleManager.ScanBLE()
        if(isAutoMode) {
            // print(" ---- isBackGround-AutoMode ---- ")
            var idx: Int = 0;
            Config.bleManager.connect(bleDevice: self.deviceInfoList[self.selectDeviceIndex].peripheral)
            isOpenDoor = true
            //print("Scan-CNT: \(scanningDeviceInfoList.count)")
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

    func didTapChooseDevice() {
        var deviceList:[String] = []
        
        for i in 0 ... deviceList.count{
            
            deviceList.append(deviceInfoList[i].name)
        }

        UIAlertController.showActionSheet(
            in: self,
            withTitle: "請選擇裝置",
            message: nil,
            cancelButtonTitle: "取消",
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
                    if self.selectDeviceIndex == (buttonIndex - controller.firstOtherButtonIndex) && self.deviceNameLabel.textColor == #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1){
                        self.selectDeviceIndex = 0
                        self.deviceNameLabel.text = self.deviceInfoList[self.selectDeviceIndex].name
                        self.deviceNameLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)

                    }else{
                

                    self.deviceNameLabel.text = self.deviceInfoList[buttonIndex - controller.firstOtherButtonIndex].name
                    self.deviceNameLabel.textColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
                        self.selectDeviceIndex = (buttonIndex - controller.firstOtherButtonIndex)
                    }
                }
            }
        }
    }
    
    @IBAction func didTapOpenDoor(_ sender: Any) {
        
        if deviceInfoList.count > 0 {
        isOpenDoor = true
        Config.bleManager.connect(bleDevice: deviceInfoList[selectDeviceIndex].peripheral)
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
    
        switch deviceFoundStatus
        {
        
        case .DeviceSearching:
        
            deviceNameLabel.text = "搜尋中..."
            deviceNameLabel.isUserInteractionEnabled = false
            deviceTypeLabel.text = "請稍後"
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
    
    
    // for test
    @IBAction func deviceSearching(_ sender: Any) {
        deviceFoundStatus = .DeviceSearching
        changeViewContentSettings()
        
        UIAlertController.showAlert(
            in: self,
            withTitle: "No Device in Range",
            message: nil,
            cancelButtonTitle: nil,
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
    
    @IBAction func LongPress(_ sender: Any) {
    print(LongPress)
        if !isKeepOpen{
         isKeepOpen = true
          Config.bleManager.connect(bleDevice: self.deviceInfoList[self.selectDeviceIndex].peripheral)
        }
    }
    
    @IBAction func deviceNotFound(_ sender: Any) {
        //deviceFoundStatus = .DeviceNotFound
        //changeViewContentSettings()
       self.loginAlert(title: "Enroll User"/*self.GetSimpleLocalizedString("enroll_dialog_title")*/ , subTitle: "", placeHolder1: "Input ID"/*self.GetSimpleLocalizedString("users_manage_add_dialog_name")*/, placeHolder2:"Input pwd"/* self.GetSimpleLocalizedString("users_manage_add_dialog_password")*/, keyboard1: .default, keyboard2: .numberPad, handler: { (input1, input2) in
            
            print("user input2: \(input1) & \(input2)")
            let userID:[UInt8] = Util.StringtoUINT8(data: input1!, len: BPprotocol.userID_maxLen, fillData: BPprotocol.nullData)
            let userPWD:[UInt8] = Util.StringtoUINT8(data: input2!, len: BPprotocol.userPD_maxLen, fillData: BPprotocol.nullData)
            if !input1!.isEmpty {
                self.isEnroll = true
                print(input1);
                if input1! == Config.AdminID{
                    print("admin enroll");
                    self.adminEnrollData = Config.bpProtocol.setAdminEnroll(UserID: userID,Password: userPWD)
                    self.isAdminEnroll = true
                    
                }
                else{
                    self.userEnrollData = Config.bpProtocol.setUserEnroll(UserID: userID, Password: userPWD)
                    print("user enroll");
                }
                Config.bleManager.connect(bleDevice: self.deviceInfoList[self.selectDeviceIndex].peripheral)
            }

        })
    }
    
    @IBAction func deviceFound(_ sender: Any) {
        deviceFoundStatus = .DeviceFound
        changeViewContentSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showSettingsTableViewController") && deviceInfoList.count > 0{
            let nvc = segue.destination  as! 
            SettingsTableViewController
            ///let vc = nvc.topViewController as! Intro_PasswordViewController
            nvc.selectedDevice = deviceInfoList[selectDeviceIndex].peripheral
        }
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if(identifier == "showSettingsTableViewController") {
            if(isAutoMode){
                //print("Need Disable 'AUTO-MODE' First!!")
                showToastDialog(title:"",message:GetSimpleLocalizedString("AUTO_ENABLE_CONFLICT" ));
                
                return false;
            }
            else if deviceInfoList.count <= 0{
                showToastDialog(title:"",message:GetSimpleLocalizedString("No found device" ));
                
                return false;
               
            }else{
                return true
            }
        }
        
        return true
    }

    public override func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
       super.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: error)
        
        if isEnroll{
            if isAdminEnroll {
               Config.bleManager.writeData(cmd: adminEnrollData, characteristic: bpChar)
            }else{
               Config.bleManager.writeData(cmd: userEnrollData, characteristic: bpChar)
            }
        
        }else if isOpenDoor {
            let isAdmin = Config.saveParam.bool(forKey: (deviceInfoList[selectDeviceIndex].peripheral.identifier.uuidString))
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
                    deviceInfoList[selectDeviceIndex].peripheral.identifier.uuidString)
                
                //self.backToMainPage()
                break
                
            case BPprotocol.cmd_user_enroll:
                
                if datalen > 1 {
                    let userIndex:Int = Int(UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF))
                    
                    print("userIndex=\(userIndex)")
                    Config.saveParam.set(userIndex, forKey: deviceInfoList[selectDeviceIndex].peripheral.identifier.uuidString + Config.userIndexTag)
                    Config.saveParam.set(false, forKey: deviceInfoList[selectDeviceIndex].peripheral.identifier.uuidString)
                    
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
    
}
