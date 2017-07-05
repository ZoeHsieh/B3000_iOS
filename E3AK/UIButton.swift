//
//  UIButton.swift
//  E3AK
//
//  Created by nsdi36 on 2017/6/19.
//  Copyright © 2017年 com.E3AK. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    func adjustButtonEdgeInsets() {
        
        let spacing:CGFloat = 6.0
        
        // lower the text and push it left so it appears centered
        //  below the image
        let imageSize = imageView?.frame.size
        titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize!.width, -(imageSize!.height + spacing), 0.0)
        // raise the image and push it right so it appears centered/        //  above the text
        let titleSize: CGSize = (titleLabel?.frame.size)!
        imageEdgeInsets = UIEdgeInsetsMake( -(titleSize.height), 0.0, 0.0, -titleSize.width)
    }
}