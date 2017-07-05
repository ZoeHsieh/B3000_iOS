//
//  UsersViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/13.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit
import CoreBluetooth
class UsersViewController: BLE_ViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var downloadView: UIView!
    @IBOutlet weak var progress_dialog_title: UILabel!
    
    @IBOutlet weak var progress_dialog_bar: UIProgressView!
    @IBOutlet weak var progress_dialog_message: UILabel!
    
    @IBOutlet weak var progress_percentage: UILabel!
    
    
    @IBOutlet weak var progress_count: UILabel!
    let  accountArr = ["Chris" , "John", "媽媽桑", "000000000000", "John", "Chris", "Chris"]
    var localUserArr:[[String:Any]] = []
    var userMax:Int16 = 0
    var userCount:Int16 = 1
    var user_read_retry_cnt = 0
    var isDownloadViewShowing:Bool = false
    var isback = false
    @IBAction func progress_hide_Action(_ sender: Any) {
    }
    @IBAction func progress_cancel_Action(_ sender: Any) {
    }
   
    @IBAction func backBefore(_ sender: Any) {
         isback = true
        print("backBefore")
        _ = self.navigationController?.popViewController(animated: true)
        if !Config.isUserListOK{
            Config.userListArr.removeAll()
            localUserArr.removeAll()
           
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "使用者"
        tableView.register(R.nib.usersTableViewCell)
          userCount = 1
        print(userMax)
        Config.bleManager.setPeripheralDelegate(vc_delegate: self)
        if userMax > 0{
            print("test")
            showDownloadDialog()
            let cmd = Config.bpProtocol.getUserInfo(UserCount: userCount)
            Config.bleManager.writeData(cmd: cmd, characteristic: bpChar!)
            
            
        }
        
        
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        
        let vc = AddUserViewController(nib: R.nib.addUserViewController)
        let navVC: UINavigationController = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func cmdAnalysis(cmd:[UInt8]){
        let datalen = Int16( UInt16(cmd[2]) << 8 | UInt16(cmd[3] & 0x00FF))
         for i in 0 ... cmd.count - 1{
         print(String(format:"r-cmd[%d]=%02x\r\n",i,cmd[i]))
         }
        if datalen == Int16(cmd.count - 4) {
            switch cmd[0]{
                
            case BPprotocol.cmd_user_info:
                print("user info")
                if !isback{
                    if cmd[4] != 0xFF && cmd[4] != 0x00 {
                        var data = [UInt8]()
                        for i in 4 ... cmd.count - 1{
                            data.append(cmd[i])
                        }
                        updateUserInfo(userData: data)
                        
                        if userCount >= userMax {
                            Config.isUserListOK = true
                            print("download ok")
                            delayOnMainQueue(delay: 0.1, closure: {
                                self.isDownloadViewShowing = false;
                                self.downloadView.removeFromSuperview();
                                
                            })
                        }
                        
                    }else{
                        user_read_retry_cnt += 1
                    }
                    
                    if userCount <= userMax {
                        if user_read_retry_cnt == 5{
                            user_read_retry_cnt = 0;
                            userCount += 1;
                        }
                        print(String(format:"retry=%d\r\n",user_read_retry_cnt))
                        let cmdData = Config.bpProtocol.getUserInfo(UserCount: Int16(userCount))
                        
                        Config.bleManager.writeData(cmd: cmdData, characteristic: bpChar)
                        
                        
                    }
                }
                break
                
                
                
            default:
                break
                
            }
        }
        
    }

    
    func updateUserInfo(userData:[UInt8]){
        var userIDArray = [UInt8]()
        for j in 0 ... BPprotocol.userID_maxLen - 1{
            if userData[j] != 0xFF && userData[j] != 0x00{
                userIDArray.append(userData[j])
            }
        }
        
        let userId = String(bytes: userIDArray, encoding: .utf8) ?? "No Name"
        
        print("user ID= \(userId)")
        var userPWDArray = [UInt8]()
        for j in 0 ... BPprotocol.userPD_maxLen - 1{
            if userData[j+16] != 0xFF && userData[j+16] != 0x00{
                userPWDArray.append(userData[j+16])
            }
        }
        
        let userPWD = String(bytes: userPWDArray, encoding: .utf8) ?? "No Name"
        
        let userIndex = Int16(UInt16(userData[24])<<8 | UInt16(userData[25] & 0x00FF))
        Config.userListArr.append(["pw":userPWD, "name":userId, "index":userIndex])
        localUserArr = Config.userListArr
        tableView.reloadData()
        
        
        let progressValue: Float = Float(userCount) / Float(userMax)
        let prog_percent: Int = Int(progressValue * 100)
        
        print(prog_percent)
        
        //Update Info
        progress_dialog_bar.setProgress(progressValue, animated: true)
        progress_percentage.text = "\(prog_percent)%"
        progress_count.text = "\(userCount) / \(userMax)"
        
        
        userCount += 1
        print(String(format:"count = %02d",userCount))
        
    }
    
    
    func showDownloadDialog() {
        
        
        //Set Initial Value
        progress_dialog_title.text = GetSimpleLocalizedString("download_dialog_title") + GetSimpleLocalizedString("settings_users_manage_list")
        progress_dialog_message.text = GetSimpleLocalizedString("download_dialog_message")
        
        downloadView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: UIScreen.main.bounds.size.height / 2)
        
        UIApplication.shared.keyWindow?.addSubview(self.downloadView);
        
        isDownloadViewShowing = true;
        progress_dialog_bar.setProgress(0, animated: true)
        progress_percentage.text = "0%"
        progress_count.text = "\(0) / \(userMax)"
       
        
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

extension UsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localUserArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.usersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
        cell.accountLabel.text = "\(localUserArr[indexPath.row]["name"] as! String)"
        cell.passwordLabel.text = "\(localUserArr[indexPath.row]["pw"] as! String)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = R.storyboard.main.userInfoTableViewController()
        navigationController?.pushViewController(vc!, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .delete
//    }
    
//    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//        return "刪除"
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        
//        if editingStyle == .delete
//        {
//            
//        } else if editingStyle == .insert
//        {
//            // Not used in our example, but if you were adding a new row, this is where you would do it.
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "刪除", handler:{action, indexpath in
            print("delete");
        });
        moreRowAction.backgroundColor = UIColor.red
        
        
        return [moreRowAction];

    }
    
    
  }