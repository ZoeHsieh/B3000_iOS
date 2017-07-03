//
//  AddUserViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/14.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit
import ChameleonFramework

protocol AddUserViewControllerDelegate {
    func didTapAdd()
}

class AddUserViewController: UIViewController {

    var delegate: AddUserViewControllerDelegate?
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "新增使用者"
        configUI()
        
    }

    func configUI() {
        
        setNavigationBarRightItemWithTitle(title: "新增")
        let leftBtn = UIButton(type: .custom)
        leftBtn.setTitle("取消", for: .normal)
        leftBtn.setTitleColor(UIColor.lightGray, for: .normal)
        leftBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        leftBtn.addTarget(self, action: #selector(didTapLeftBarButtonItem), for: .touchUpInside)
        let leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        accountTextField.setTextFieldPaddingView()
        accountTextField.setTextFieldBorder()
        
        passwordTextField.setTextFieldPaddingView()
        passwordTextField.setTextFieldBorder()
        
        userNameTextField.setTextFieldPaddingView()
        userNameTextField.setTextFieldBorder()
    }
    
    func didTapLeftBarButtonItem() {
        dismiss(animated: true, completion: nil)
    }
    
    override func didTapItem() {
        
        delegate?.didTapAdd()
        dismiss(animated: true, completion: nil)
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
