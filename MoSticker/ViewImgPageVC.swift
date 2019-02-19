//
//  ViewImgPageVC.swift
//  MoSticker
//
//  Created by Moses Mok on 15/2/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

class ViewImgPageVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var images = [UIImage?]()
    var index: Int = 0 {
        didSet {
            indexChangedAction?(index)
        }
    }
    var indexChangedAction: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        goToVC(at: index)
    }
    
    func goToVC(at index: Int) {
        if let contentVC = getContentVC(at: index) {
            setViewControllers([contentVC], direction: (index >= self.index) ? .forward : .reverse, animated: true, completion: nil)
        }
    }
    func getContentVC(current vc: UIViewController, indexOffset: Int) -> ViewImgPageContentVC? {
        guard let contentVC = vc as? ViewImgPageContentVC,
            let index = contentVC.index else {
            printError("Either vc is not a ViewImgPageContentVC, or contentVC.index is nil.")
            return nil
        }
        
        return getContentVC(at: index + indexOffset)
    }
    func getContentVC(at index: Int) -> ViewImgPageContentVC? {
        guard index >= 0 && index < images.count else { return nil }
        
        let storyboard = UIStoryboard(name: Rc.storyboardName, bundle: nil)
        guard let contentVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: ViewImgPageContentVC.self))
            as? ViewImgPageContentVC else { return nil }
        contentVC.index = index
        contentVC.image = images[index]
        contentVC.appearAction = { index in
            guard let index = index else { return }
            self.index = index
        }
        
        return contentVC
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getContentVC(current: viewController, indexOffset: -1)
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getContentVC(current: viewController, indexOffset: 1)
    }
}
