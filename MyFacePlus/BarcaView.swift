//
//  BarcaView.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/11.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit

class BarcaView: UIView {
    @IBOutlet weak var iconView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        frame = CGRect(x: 0, y: 64, width: screenWidth, height: screenHeight - 64 - 160)
        backgroundColor = UIColor.init(white: 0, alpha: 0)
        
        let defaultSize = CGFloat(44)
        setIconPosition((screenWidth - defaultSize) / 2, (screenHeight - defaultSize) / 2, defaultSize, defaultSize)
    }
}

extension BarcaView {
    fileprivate func setIconPosition(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        iconView.frame = CGRect(x: x, y: y, width: w, height: h)
    }
}
