//
//  ConfirmController.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/11.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit

class ConfirmController: AppViewController {
    @IBOutlet weak var photoView : UIImageView!
    
    // params.
    var photo : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ConfirmController {
    fileprivate func setView() {
        photoView.image = photo
    }
}
