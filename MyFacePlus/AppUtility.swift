//
//  AppUtility.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/12.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit

class AppUtility {
    static func getHeight(by width : CGFloat, _ text : String, _ font : UIFont) -> CGFloat {
        let attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName : font])
        let rect = attributedText.boundingRect(with: CGSize(width: width, height : 2000), options: .usesLineFragmentOrigin, context: nil)
        return rect.height
        
    }
    
    static func getWidth(by height : CGFloat, _ text: String, _ font: UIFont) -> CGFloat {
        let attributedText = NSAttributedString(string: text, attributes: [NSFontAttributeName : font])
        let rect = attributedText.boundingRect(with: CGSize(width: 2000, height : height), options: .usesLineFragmentOrigin, context: nil)
        return rect.width
    }
}
