//
//  DatePickerTableViewCell.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/16.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import UIKit

protocol DatePickerTableViewCellDelegate {
    func didSelectDate(_ sender: UIDatePicker)
}

class DatePickerTableViewCell: UITableViewCell {

    var delegate: DatePickerTableViewCellDelegate?
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func didSelectDate(_ sender: UIDatePicker) {
        delegate?.didSelectDate(sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
