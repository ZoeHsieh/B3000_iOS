//
//  config.swift
//  CBDoorLock
//
//  Created by BluePacket on 2017/3/30.
//  Copyright © 2017年 鄭詠元. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
class Config{
    
    public static let BLE_RSSI_MAX = -35;
    public static let BLE_RSSI_MIN = -115;
    public static let BLE_RSSI_SCALE = BLE_RSSI_MAX - BLE_RSSI_MIN;
    public static let BLE_RSSI_LEVEL_MAX = 20;
    public static let BLE_RSSI_LEVEL_DEFAULT = 10;
    public static let BLE_RSSI_LEVEL_MIN = 0;
    public static let BLE_RSSI_LEVEL_SCALE = BLE_RSSI_LEVEL_MAX - BLE_RSSI_LEVEL_MIN;
    public static let BLE_RSSI_LEVEL_CONVERT_BASE = BLE_RSSI_SCALE / BLE_RSSI_LEVEL_SCALE;
        
    public static let userMac = [UIDevice.current.identifierForVendor!.uuid.10,
                              UIDevice.current.identifierForVendor!.uuid.11,
                              UIDevice.current.identifierForVendor!.uuid.12,
                              UIDevice.current.identifierForVendor!.uuid.13,
                              UIDevice.current.identifierForVendor!.uuid.14,
                              UIDevice.current.identifierForVendor!.uuid.15]
    public static let serviceUUID = "0000E0FF-3C17-D293-8E48-14FE2E4DA212"
    public static let charUUID = "0000FFE1-0000-1000-8000-00805F9B34FB"
    public static let AdminID = "ADMIN."
    public static let AdminPWDDef = "12345"
    public static let bp_addr = "00:12:A1"
    public static let user_limit_def:UInt8 = 0x00
    public static let user_keypad_unlock_def:UInt8 = 0x00
    public static let disConTimeOut:Double = 6
    public static let ConTimeOut:Double = 6
    public static let userIndexTag:String = "userIndex"
    public static let saveParam  = UserDefaults.standard
    public static let BLE_MTU_MAX = 20
    public static let check_version:Float = 1.05
    public static let bleManager:BluetoothLEDevice = BluetoothLEDevice()
    public static let bpProtocol:BPprotocol = BPprotocol();
    public static let adminSettingMenuItem:Int = 9
    public static let DOOR_DELAY_TIME_LIMIT:Int16 = 1800
    public static let  doorActionItem: Array = [NSLocalizedString("Use Re-lock Time", comment: ""), NSLocalizedString("Door Always Unlocked", comment: ""), NSLocalizedString("Door Always Locked", comment: "")]
    public static let accessTypesArray = [NSLocalizedString("Permanent", comment: ""), NSLocalizedString("Schedule", comment: ""), NSLocalizedString("Access Times", comment: ""),NSLocalizedString("Recurrent", comment: "") ]
    public static let  weekArr = [
         NSLocalizedString("Sunday", comment: ""),
         NSLocalizedString("Monday", comment: ""),
         NSLocalizedString("Tuesday", comment: ""),
         NSLocalizedString("Wednesday", comment: ""),
         NSLocalizedString("Thursday", comment: ""),
         NSLocalizedString("Friday", comment: ""),
         NSLocalizedString("Saturday", comment: "")]
    public static var isUserListOK = false
    public static var isHistoryDataOK = false
    public static var historyListArr: [[String:Any]] = []
    public static var userListArr: [[String:Any]] = []
    public static var ADMINPWD:String = ""
    public static var deviceName:String = ""
    public static var doorSensor: UInt8?
    public static var doorLockType: UInt8?
    public static var doorOpenTime: UInt16?
    public static var TamperSensor: UInt8?
    public static var userDataArr:[UInt8] = []
    public static var userDeleted: String?
    public static let RSSI_LEVEL_Tag:String = "RSSI"
    public static let RSSI_DB_EXIST:String = "RSSI_EXIST"
    public static let ConfigTag_backup:String = "DEVICE_CONFIG"
    public static let DeviceNameTag_backup:String = "DEVICE_NAME"
    public static let ADMIN_PWDTag_backup:String = "ADMIN_PWD"
    public static let User_ListTag_backup:String = "USERLIST"
    public static let ConfigDoorSensorTag:String = "doorSensor"
    public static let ConfigDoorLockTypeTag:String = "doorLockType"
    public static let ConfigDoorOpenTimeTag:String = "doorOpenTime"
    public static let ConfigGSensorTag:String = "GSensor"
    public static let ConfigADMIN_MACTag:String = "adminMac"
    public static let backupOK = "backupOK"
    public static let firstOpen = "FirstOpen"
    //public static let SCAN_TIME_INTRO:Int = 10
}
