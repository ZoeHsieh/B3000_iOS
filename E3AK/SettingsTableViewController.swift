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

class SettingsTableViewController: BLE_tableViewController {

    @IBOutlet weak var usersButton: UIButton!
    @IBOutlet weak var activityHistoryButton: UIButton!
    @IBOutlet weak var backupButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    @IBOutlet var loadingView: UIView!
    var settingItemNum:Int  = 0
    var selectedDevice:CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
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
            
        })
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
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
        
    }
    
    @IBAction func didTapActivityHistory(_ sender: Any) {
        let vc = ActivityHistoryViewController(nib: R.nib.activityHistoryViewController)
        navigationController?.pushViewController(vc, animated: true)
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 8//settingItemNum
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
            showDeviceNameAlert()
        
        case 2:
            let vc = DoorLockActionViewController(nib: R.nib.doorLockActionViewController)
            navigationController?.pushViewController(vc, animated: true)
        
        case 4:
            let vc = ProximityReadRangeViewController(nib: R.nib.proximityReadRangeViewController)
            navigationController?.pushViewController(vc, animated: true)
        
        case 5:
            let vc = DoorRe_lockTimeViewController(nib: R.nib.doorReLockTimeViewController)
            navigationController?.pushViewController(vc, animated: true)
        
        case 6:
            let vc = DeviceTimeViewController(nib: R.nib.deviceTimeViewController)
            navigationController?.pushViewController(vc, animated: true)
        
        case 7:
            let vc = AboutUsViewController(nib: R.nib.aboutUsViewController)
            navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
    
    func showDeviceNameAlert() {
        
        let alertController = UIAlertController(title: "編輯裝置名稱", message: "最多16個位元組", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            alert -> Void in
            _ = alertController.textFields![0] as UITextField
            // do something with textField
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "E3AK001"
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    public override func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        super.centralManager(central, didConnect: peripheral)
    
        setUIVisable(enable: true)
        
        
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
    
    
     

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
