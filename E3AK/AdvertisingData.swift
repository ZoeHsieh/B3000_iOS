//
//  File.swift
//  E3AK
//
//  Created by 謝宇琋 on 2018/6/11.
//  Copyright © 2018年 com.E3AK. All rights reserved.
//

import Foundation

class AdvertisingData{
    //Custom ID list   客戶列表
    public static let CUSTOM_IDs:[UInt16:String] = [
        0x0000:"custom1"
        ,0x0001:"ROFU"
        ,0xFFFE:"GEM"
        ,0xFFFF:"ANXELL"
        
    ]
    //Device Model list   客戶裝置型號
    public static let dev_Model:[UInt16:String] = [
        0x0000:"E3A2-14"
        ,0x0001:"E3A2-14A"
        ,0x0002:"BK-3000B"
        ,0x0003:"E3AK1-14A"
        ,0x0004:"E3AK2-14"
        ,0x0005:"E3AK2-14A"
        ,0x0006:"BK-3000S"
        ,0x0007:"E3AK3-14A"
        ,0x0008:"E3AK4-14"
        ,0x0009:"E3AK4-14A"
        ,0x000A:"E3AK5"
        ,0x000B:"E3AK6"
        ,0x000C:"E3AK6-WI"
        ,0x000D:"BC-5900B"  //e5ar
        ,0x000E:"BKC-5000B"   //e5ak BKC-5000B DG-800⁺
        ,0x000F:"xxxyyy"   //e5ar2
        ,0x0010:"xxxxyyyy"   //e5ar2
        ,0xFFFF:"xxxxxxxx"
    ]
    
    //Device Category list
    public static let dev_Category:[UInt8:String] = [
        0x00:"Reader"
        ,0x01:"Keypad"
        ,0x02:"Reader(EM)"
        ,0x03:"Keypad(EM)"
        ,0x04:"Reader(Mifare)"
        ,0x05:"Keypad(Mifare)"
        ,0x06:"TouchPanel"
        ,0x07:"Keypad(EM)+TouchPanel"
        ,0x08:"Reader(Mifare)+TouchPanel"]
    
    
    
    public static let dev_Reserved:[UInt8:String] = [
        0x00:"xxxx"
        ,0x01:"xxxx"
        ,0xFF:"xxxx"
        
    ]
    
    
    
    
}
