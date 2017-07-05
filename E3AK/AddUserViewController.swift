//
//  AddUserViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/14.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit
import ChameleonFramework
import CoreBluetooth

protocol AddUserViewControllerDelegate {
    func didTapAdd()
}

class AddUserViewController: BLE_ViewController {

    var delegate: AddUserViewControllerDelegate?
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var tmpID:String = ""
    var tmpPassword:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "新增使用者"
        configUI()
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        accountTextField.tag = 0
        accountTextField.addTarget(self, action: #selector(self.userAddTextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        passwordTextField.tag = 1
        passwordTextField.addTarget(self, action: #selector(self.userAddTextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        passwordTextField.keyboardType = .numberPad
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    func configUI() {
        
        setNavigationBarRightItemWithTitle(title: "新增")
        let leftBtn = UIButton(type: .custom)
        leftBtn.setTitle("取消", for: .normal)
        leftBtn.setTitleColor(UIColor.flatGreen, for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        leftBtn.addTarget(self, action: #selector(didTapLeftBarButtonItem), for: .touchUpInside)
        let leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        accountTextField.setTextFieldPaddingView()
        accountTextField.setTextFieldBorder()
        
        passwordTextField.setTextFieldPaddingView()
        passwordTextField.setTextFieldBorder()
        
       
    }
    
    override func cmdAnalysis(cmd:[UInt8]){
        let datalen = Int16( UInt16(cmd[2]) << 8 | UInt16(cmd[3] & 0x00FF))
        for i in 0 ... cmd.count - 1{
            print(String(format:"r-cmd[%d]=%02x\r\n",i,cmd[i]))
        }
        if datalen == Int16(cmd.count - 4) {
            switch cmd[0]{
                
            case BPprotocol.cmd_user_add:
                UsersViewController.result_userAction = 0
                if datalen == 2{
                    
                    let userIndex = Int16( UInt16(cmd[4]) << 8 | UInt16(cmd[5] & 0x00FF))
                    print("tmp id2= \(tmpID)")
                    print("tmp pwd2= \(tmpPassword))")
                    
                    Config.userListArr.append(["pw": tmpPassword, "name":tmpID,"index":userIndex])
                    
                    
                    
                }
                else{
                   UsersViewController.result_userAction = 1
                    
                }
                UsersViewController.status = userViewStatesCase.userAction.rawValue
                dismiss(animated: true, completion: nil)
                break

                
            default:
                break
                
            }
        }
        
    }
    func userAddTextFieldDidChange(field: UITextField){
        
        
        
        if field.tag == 0{// for user id
            
            if ( (field.text?.utf8.count)! > BPprotocol.userID_maxLen ){
                field.deleteBackward();
            }
       
     self.navigationItem.rightBarButtonItem?.isEnabled = ((field.text?.utf8.count)! >= 1 ) && ((self.passwordTextField.text?.utf8.count)! >= 4)
            
        }else if field.tag == 1{ // for user pwd
            
            if ( (field.text?.utf8.count)! > BPprotocol.userPD_maxLen ) {
                field.deleteBackward();
            }
         self.navigationItem.rightBarButtonItem?.isEnabled = ((field.text?.characters.count)! >= 4 ) && ((self.accountTextField.text?.utf8.count)! >= 1 )
        }
        
        
        //Check Length
        
        
    }

    func didTapLeftBarButtonItem() {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    override func didTapItem() {
        if !(accountTextField?.text?.isEmpty)! && !(passwordTextField?.text?.isEmpty)!{
            guard (passwordTextField?.text?.characters.count)! > 3 && (passwordTextField?.text?.characters.count)! < BPprotocol.userPD_maxLen+1 else{
                
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_pwd"))
                return
            }
            
            let nameArr = Config.userListArr.map{ $0["name"] as! String }
            let pwArr = Config.userListArr.map{ $0["pw"] as! String }
            
            print("name size = \(nameArr.count)")
            if nameArr.contains((accountTextField?.text!)!){
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_name"))
                return
            }
            
            if accountTextField?.text == Config.AdminID || accountTextField?.text == "ADMIN"{
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_name"))
                return
            }
           
            
            if pwArr.contains((passwordTextField.text)!){
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_duplication_password"))
                return
                
            }
            if  passwordTextField.text == Config.ADMINPWD{
                
                self.showToastDialog(title: "", message: self.GetSimpleLocalizedString("users_manage_edit_status_Admin_pwd"))
                return
                
            }
            
            tmpID = accountTextField.text!
            tmpPassword = passwordTextField.text!
            print("tmp id= \(tmpID)")
            print("tmp pwd= \(tmpPassword)")
            
            let userID:[UInt8] = Util.StringtoUINT8(data: tmpID, len: BPprotocol.userID_maxLen, fillData: BPprotocol.nullData)
            
            let userPWD:[UInt8] = Util.StringtoUINT8(data: tmpPassword, len: BPprotocol.userPD_maxLen, fillData: BPprotocol.nullData)
            
            let cmdData = Config.bpProtocol.setUserAdd(Password: userPWD, ID: userID, KeypadUnlock: Config.user_keypad_unlock_def, limitType: Config.user_limit_def)
            for i in 0 ... cmdData.count - 1 {
                print("cmd add=%02x",cmdData[i])
            }
            
            Config.bleManager.writeData(cmd: cmdData, characteristic: self.bpChar!)
            
        }
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}
