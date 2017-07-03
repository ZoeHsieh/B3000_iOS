//
//  ActivityHistoryViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/12.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit
import ChameleonFramework

class ActivityHistoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let  dataArr = ["Chris" , "John", "媽媽桑", "000000000000", "John", "Chris", "Chris"]
    let  deviceArr = ["Android" , "iOS", "Android" , "Keypad" , "iOS","Android" , "iOS"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "歷史進出記錄"
        tableView.register(R.nib.activityHistoryTableViewCell)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: (R.image.researchGreen()), style: .done, target: self, action: #selector(didTapReloadItem)),
            UIBarButtonItem(image: (R.image.export()), style: .done, target: self, action: #selector(didTapshareItem))]
        
        navigationItem.rightBarButtonItem?.tintColor = HexColor("00B900")
    }
    
    func didTapReloadItem() {
        
        print("didTapReloadItem")
    }
    
    func didTapshareItem() {
        
        print("didTapshareItem")
        let activityViewController = UIActivityViewController(activityItems: ["分享"], applicationActivities: nil)
        navigationController?.present(activityViewController, animated: true) {
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension ActivityHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.activityHistoryTableViewCell.identifier, for: indexPath) as! ActivityHistoryTableViewCell
        cell.nameLabel.text = "\(dataArr[indexPath.row])"
        cell.deviceLabel.text = "\(deviceArr[indexPath.row])"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

