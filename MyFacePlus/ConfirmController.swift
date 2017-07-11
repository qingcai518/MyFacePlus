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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

extension ConfirmController {
    fileprivate func setView() {
        photoView.image = photo
    }
}

extension ConfirmController {
    @IBAction func doClose() {
        dismiss(animated: true, completion: nil)
    }
}
