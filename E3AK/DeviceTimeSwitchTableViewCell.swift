//
//  DeviceTimeSwitchTableViewCell.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/21.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit

protocol DeviceTimeSwitchTableViewCellDelegate {
    func didTapSettingSwitch(_ indexPath: IndexPath)
}

class DeviceTimeSwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    var indexPath: IndexPath!
    var delegate: DeviceTimeSwitchTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func didTapSettingSwitch(_ sender: UISwitch) {
    
        delegate?.didTapSettingSwitch(indexPath)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
