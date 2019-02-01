//
//  PETaggingVC.swift
//  MoSticker
//
//  Created by Moses Mok on 13/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit

class PETaggingVC: UIViewController, UIScrollViewDelegate, PEToolOptVCDelegate {
    
    var curImage: UIImage!
    var brushLayer: UIImage!
    
    var toolOptions = PEToolOptions()
    
    @IBOutlet weak var imageView: PanningImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var allowScrollButton: UIBarButtonItem!
    @IBOutlet weak var brushButton: UIBarButtonItem!
    @IBOutlet weak var eraserButton: UIBarButtonItem!
    @IBOutlet weak var textButton: UIBarButtonItem!

    var _modeIndex = 0
    var modeIndex: Int {
        get { return _modeIndex }
        set {
            _modeIndex = newValue
            
            allowScrollButton.image = UIImage(named: PETaggingVC.DISABLE_SCROLL_ICON_NAME)
            brushButton.image = UIImage(named: PETaggingVC.DISABLE_BRUSH_ICON_NAME)
            eraserButton.image = UIImage(named: PETaggingVC.DISABLE_ERASER_ICON_NAME)
            textButton.image = UIImage(named: PETaggingVC.DISABLE_TEXT_ICON_NAME)
            scrollView.isScrollEnabled = false
            scrollView.pinchGestureRecognizer?.isEnabled = false

            switch _modeIndex {
            case 0:
                allowScrollButton.image = UIImage(named: PETaggingVC.ENABLE_SCROLL_ICON_NAME)
                scrollView.isScrollEnabled = true
                scrollView.pinchGestureRecognizer?.isEnabled = true
            case 1:
                brushButton.image = UIImage(named: PETaggingVC.ENABLE_BRUSH_ICON_NAME)
            case 2:
                eraserButton.image = UIImage(named: PETaggingVC.ENABLE_ERASER_ICON_NAME)
            case 3:
                textButton.image = UIImage(named: PETaggingVC.ENABLE_TEXT_ICON_NAME)
            default:
                printError("Unknown index: newValue is \(newValue).")
            }
        }
    }
    
    static let DISABLE_SCROLL_ICON_NAME = "move_arrows_disabled"
    static let ENABLE_SCROLL_ICON_NAME = "move_arrows_enabled"
    static let DISABLE_BRUSH_ICON_NAME = "brush_disabled"
    static let ENABLE_BRUSH_ICON_NAME = "brush_enabled"
    static let ENABLE_ERASER_ICON_NAME = "eraser_enabled"
    static let DISABLE_ERASER_ICON_NAME = "eraser_disabled"
    static let DISABLE_TEXT_ICON_NAME = "text_insert_disabled"
    static let ENABLE_TEXT_ICON_NAME = "text_insert_enabled"
    static let TO_PETOOLOPT_SEGUE_ID = "PETagging-PEToolOpt"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = curImage
        
        UIGraphicsBeginImageContextWithOptions(curImage.size, false, 0.0)
        UIColor.clear.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: curImage.size))
        brushLayer = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let topDistance = self.calculateTopDistance()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 2 * topDistance, right: 0)
        scrollView.zoomScale = 1
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
    func options(_ toolOpt: PEToolOptVC) -> PEToolOptions {
        return toolOptions
    }
    func toolOpt(_ toolOpt: PEToolOptVC, didFinish options: PEToolOptions) {
        toolOptions = options
    }
    @IBAction func modeBarButtonPressed(_ sender: UIBarButtonItem) {
        switch sender {
        case allowScrollButton:
            modeIndex = 0
        case brushButton:
            modeIndex = 1
        case eraserButton:
            modeIndex = 2
        case textButton:
            modeIndex = 3
        default:
            print("Unknown sender: sender is \(sender).")
        }
    }
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
//        if modeIndex != 0 || modeIndex != 3,
//            let startingPoint = imageView.panningStartPoint {
//            let touchingPoint = startingPoint.added(with: sender.translation(in: imageView))
//            let pointOnImg = touchingPoint.mul(factor: curImage.size.width / view.frame.width)
//
//            if modeIndex == 1 {
//                UIGraphicsBeginImageContextWithOptions(curImage.size, false, 0.0)
//                brushLayer.draw(in: CGRect(origin: CGPoint.zero, size: maskImage.size))
//
//                let brushColor = // TODO:
//                let brushSize = calculateBrushSize()
//                createCirlce(radius: brushSize, color: brushColor)!.draw(at: pointOnImg.added(with: CGPoint(x: -brushSize / 2, y: -brushSize / 2)))
//                maskImage = UIGraphicsGetImageFromCurrentImageContext()
//
//                UIGraphicsEndImageContext()
//            }
//        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        showPopConfirmation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PETaggingVC.TO_PETOOLOPT_SEGUE_ID,
            let dvc = segue.destination as? PEToolOptVC {
            
            dvc.delegate = self
        }
    }
}
