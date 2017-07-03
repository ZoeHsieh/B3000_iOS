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
    
    @IBAction func settingBtnListener(_ sender: Any) {
        
        if deviceInfoList.count > 0 {
            
            
        }else{
        
        
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        gradientView.gradientBackground(percent: 250/667)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapChooseDevice))
        deviceNameLabel.addGestureRecognizer(gestureRecognizer)
        openDoorButton.setBackgroundImage(R.image.btnGreen(), for: .normal)
        openDoorButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        settingsButton.adjustButtonEdgeInsets()
         Config.bleManager.Init(delegate: self)
        changeViewContentSettings()
        deviceNameLabel.text = ""
        deviceTypeLabel.text = ""
        Config.bleManager.setCentralManagerDelegate(vc_delegate: self)
        Config.bleManager.ScanBLE()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
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
        
        // let expect_level: Int = readExpectLevelFromDbByUUID(uuid.uuidString);
        
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
                
                //print("RSSI: \(RSSI.intValue), LEVEL: \(tmp.current_level)")
                
                deviceInfoList[du_idx] = tmp;
            }
            else {
                deviceInfoList.append(tmp)
                deviceNameLabel.text = deviceInfoList[0].name
                //Save to DB
                //  saveExpectLevelToDbByUUID(uuid.uuidString, expect_level)
            }
        }
        
        
        deviceInfoList.sort();
        
        
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
    
    @IBAction func didTapDoorCheck(_ sender: Any) {
        doorCheckButton.setImage(R.image.checkboxTick(), for: .normal)
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
            
            deviceNameLabel.text = "E3AK001"
            deviceNameLabel.isUserInteractionEnabled = true
            deviceTypeLabel.text = "型號ABC123"
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
    
    @IBAction func deviceNotFound(_ sender: Any) {
        deviceFoundStatus = .DeviceNotFound
        changeViewContentSettings()
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
        if (segue.identifier == "showSettingsTableViewController") {
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
            else if deviceInfoList.count < 0{
                showToastDialog(title:"",message:GetSimpleLocalizedString("No found device" ));
                
                return false;
               
            }else{
                return true
            }
        }
        
        return true
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
