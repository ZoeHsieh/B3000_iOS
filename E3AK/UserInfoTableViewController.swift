//
//  UserInfoTableViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/15.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit
import UIAlertController_Blocks

class UserInfoTableViewController: UITableViewController {

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        accountTextField.setTextFieldPaddingView()
        passwordTextField.setTextFieldPaddingView()
        userNameTextField.setTextFieldPaddingView()
    }

    @IBAction func didTapDelete(_ sender: Any) {
        UIAlertController.showAlert(
            in: self,
            withTitle: "確定要刪除？",
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
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch (section)
        {
        case 3:
            return 2;
        default:
            return 1;
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 3 && indexPath.row == 1
        {
            let vc = AccessTypesViewController(nib:R.nib.accessTypesViewController)
            navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
            navigationController?.pushViewController(vc, animated: true)
            
        }
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
