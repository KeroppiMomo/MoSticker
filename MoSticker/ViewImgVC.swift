//
//  ViewImgVC.swift
//  MoSticker
//
//  Created by Moses Mok on 18/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit
class ViewImgVC: UIViewController {
    
    var image: UIImage?
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
    
    @IBAction func sharePressed(_ sender: UIBarButtonItem) {
        let activityVC = UIActivityViewController(activityItems: [(image ?? UIImage()).pngData()!], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
}
