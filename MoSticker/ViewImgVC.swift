//
//  ViewImgVC.swift
//  MoSticker
//
//  Created by Moses Mok on 18/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit
class ViewImgVC: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var images = [UIImage?]()
    var index = 0
    
    var pageVC: ViewImgPageVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.numberOfPages = images.count
    }
    
    @IBAction func sharePressed(_ sender: UIBarButtonItem) {
        let image = images[pageVC.index]
        let activityVC = UIActivityViewController(activityItems: [(image ?? UIImage()).pngData()!], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    @IBAction func pageControlChanged(_ sender: UIPageControl) {
        let index = sender.currentPage
        pageVC.goToVC(at: index)
    }
    func pageIndexChanged(_ index: Int) {
        pageControl.currentPage = index
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.VIVCs.pageVCEmbedSegueID,
            let dvc = segue.destination as? ViewImgPageVC {
            dvc.images = images
            dvc.index = index
            
            dvc.indexChangedAction = pageIndexChanged(_:)
            self.pageVC = dvc
        }
    }
}
