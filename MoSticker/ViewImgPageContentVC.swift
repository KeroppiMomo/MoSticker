//
//  ViewImgPageContentVC.swift
//  MoSticker
//
//  Created by Moses Mok on 15/2/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

class ViewImgPageContentVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    var index: Int?
    
    var appearAction: ((Int?) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appearAction?(index)
    }
}
