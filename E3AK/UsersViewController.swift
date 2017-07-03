//
//  UsersViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/13.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let  accountArr = ["Chris" , "John", "媽媽桑", "000000000000", "John", "Chris", "Chris"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "使用者"
        tableView.register(R.nib.usersTableViewCell)
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
        return accountArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.usersTableViewCell.identifier, for: indexPath) as! UsersTableViewCell
        cell.accountLabel.text = "\(accountArr[indexPath.row])"
        
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
