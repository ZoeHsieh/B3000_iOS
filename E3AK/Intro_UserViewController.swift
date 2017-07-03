//
//  Intro_UserViewController.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/12.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit
import ChameleonFramework

class Intro_UserViewController: UIViewController {

    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    var isNOUser = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rightButton.addTarget(self, action: #selector(didTapSkipItem), for: .touchUpInside)
        nextButton.setShadowWithColor(color: HexColor("00b900"), opacity: 0.3, offset: CGSize(width: 0, height: 6), radius: 5, viewCornerRadius: 0)
        
        add(asChildViewController: Intro_NOUsersViewController(nib: R.nib.intro_NOUsersViewController))
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        
        if isNOUser
        {
            showAddUserViewController()
        }
        else
        {
            showIntro_DistanceSettingsViewController()
        }
    }
    
    func showAddUserViewController() {
        let vc = AddUserViewController(nib: R.nib.addUserViewController)
        let navVC: UINavigationController = UINavigationController(rootViewController: vc)
        vc.delegate = self
        present(navVC, animated: true, completion: nil)
    }
    
    func showIntro_DistanceSettingsViewController() {
        let vc = R.storyboard.intro.intro_DistanceSettingsViewController()
        navigationController?.pushViewController(vc!, animated: true)
    }
    
    func swapViewController(from: UIViewController, to: UIViewController) {
        
    }
    
    func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        containerView.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
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

extension Intro_UserViewController: AddUserViewControllerDelegate{
    
    func didTapAdd() {
        
        if isNOUser
        {
            nextButton.setTitle("下一步", for: .normal)
            remove(asChildViewController: Intro_NOUsersViewController(nib: R.nib.intro_NOUsersViewController))
            add(asChildViewController: Intro_AddMoreUserViewController(nib: R.nib.intro_AddMoreUserViewController))
            
            isNOUser = false
        }
    }

    
    
}
