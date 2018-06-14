//
//  UserFAQ.swift
//  E3AK
//
//  Created by twkazuya on 2017/11/6.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit


class UserFAQ: ViewController {
    
    @IBOutlet weak var tit_auto_proximity_range: UILabel!
    @IBOutlet weak var dsc_auto_proximity_range: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = GetSimpleLocalizedString("tooltip_FAQ")
        
        tit_auto_proximity_range.text = GetSimpleLocalizedString("Proximity Read Range")
        dsc_auto_proximity_range.text = GetSimpleLocalizedString("tooltip_dsc_proximity_read_range")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

