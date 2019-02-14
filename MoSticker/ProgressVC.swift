//
//  ProgressVC.swift
//  MoSticker
//
//  Created by Moses Mok on 11/2/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

class ProgressVC: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    var message = ""

    override func loadView() {
        super.loadView()
        Bundle.main.loadNibNamed(String(describing: ProgressVC.self), owner: self, options: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = message
    }
    
    func update(progress: Float) {
        self.progressView.setProgress(progress, animated: true)
    }
    
    static func setup(withMessage message: String) -> ProgressVC {
        let progressVC = ProgressVC()
        progressVC.modalTransitionStyle = .crossDissolve
        progressVC.modalPresentationStyle = .overFullScreen
        progressVC.message = message
        
        return progressVC
    }
}
