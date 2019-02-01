//
//  ProgressVC.swift
//  MoSticker
//
//  Created by Moses Mok on 5/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

class LoadingVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    var message = ""
    
    override func loadView() {
        super.loadView()
        Bundle.main.loadNibNamed(String(describing: LoadingVC.self), owner: self, options: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = message
    }
    
    static func setup(withMessage message: String) -> LoadingVC {
        let loadingVC = LoadingVC()
        loadingVC.modalTransitionStyle = .crossDissolve
        loadingVC.modalPresentationStyle = .overFullScreen
        loadingVC.message = message
        
        return loadingVC
    }
}
