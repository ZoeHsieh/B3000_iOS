//
//  RepeatDateViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/16.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit

class RepeatDateViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let  dateArr = ["一" , "二", "三", "四", "五", "六", "天"]
    var selectedDateArray = [Bool](repeating: false, count: 7)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "選擇週期"
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

extension RepeatDateViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.selectionStyle = .none
        cell.textLabel?.text = "星期\(dateArr[indexPath.row])"
        cell.imageView?.image = selectedDateArray[indexPath.row] ? R.image.tickGreen() : R.image.tickWhiteS()

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDateArray[indexPath.row] = !selectedDateArray[indexPath.row]
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
