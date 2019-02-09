//
//  PETaggingVC.swift
//  MoSticker
//
//  Created by Moses Mok on 13/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit

class PETaggingVC: UIViewController, UIScrollViewDelegate {
    
    var delegate: PEDelegate?
    var curImage: UIImage!
    var brushLayer: UIImage!
    var brushCached: UIImage!
    
    var curColor = UIColor.red
    
    @IBOutlet weak var imageView: PanningImageView!
    @IBOutlet weak var layerImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var allowScrollButton: UIBarButtonItem!
    @IBOutlet weak var brushButton: UIBarButtonItem!
    @IBOutlet weak var textButton: UIBarButtonItem!
    @IBOutlet weak var curColorButton: UIButton!

    var _modeIndex = 0
    var modeIndex: Int {
        get { return _modeIndex }
        set {
            _modeIndex = newValue
            
            allowScrollButton.image = R.PE.TagVC.disableScrollIcon
            brushButton.image = R.PE.TagVC.disableBrushIcon
            textButton.image = R.PE.TagVC.disableTextIcon
            scrollView.isScrollEnabled = false
            scrollView.pinchGestureRecognizer?.isEnabled = false

            switch _modeIndex {
            case 0:
                allowScrollButton.image = R.PE.TagVC.enableScrollIcon
                scrollView.isScrollEnabled = true
                scrollView.pinchGestureRecognizer?.isEnabled = true
            case 1:
                brushButton.image = R.PE.TagVC.enableBrushIcon
            case 2:
                textButton.image = R.PE.TagVC.enableTextIcon
            default:
                printError("Unknown index: newValue is \(newValue).")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = curImage
        
        UIGraphicsBeginImageContextWithOptions(curImage.size, false, 0.0)
        brushLayer = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cachedSize = CGSize(width: R.PE.cachedImgRes, height: R.PE.cachedImgRes)
        
        UIGraphicsBeginImageContextWithOptions(cachedSize, false, 0.0)
        brushCached = UIGraphicsGetImageFromCurrentImageContext()
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
    @IBAction func modeBarButtonPressed(_ sender: UIBarButtonItem) {
        switch sender {
        case allowScrollButton:
            modeIndex = 0
        case brushButton:
            modeIndex = 1
        case textButton:
            modeIndex = 2
        default:
            print("Unknown sender: sender is \(sender).")
        }
    }
    @IBAction func colorPressed(_ sender: UIButton) {
        performSegue(withIdentifier: R.PE.TagVC.toColorPickerSegueID, sender: curColor)
    }
    func colorPickerCompletion(_ color: UIColor) {
        curColor = color
        curColorButton.backgroundColor = curColor
        self.dismiss(animated: true, completion: nil)
    }
    
    func calculateBrushSize() -> CGFloat {
        return 30 / scrollView.zoomScale
    }
    
    var panPathPts = [CGPoint]()
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        if modeIndex == 1,
            let startingPoint = imageView.panningStartPoint {
            
            func draw(brushSize: CGFloat, image: UIImage) -> UIImage {
                let result: UIImage!
                
                let touchingPoint = startingPoint.added(with: sender.translation(in: imageView))
                let pointOnImg = touchingPoint.mul(factor: image.size.width / view.frame.width)
                panPathPts.append(pointOnImg.mul(factor: brushLayer.size.width / brushCached.size.width))
                
                UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
                image.draw(at: .zero)
                createCirlce(radius: brushSize, color: curColor)!.draw(at: pointOnImg.added(with: CGPoint(x: -brushSize / 2, y: -brushSize / 2)))
                result = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                return result
            }
            
            if sender.state == .changed {
                let brushSize = self.calculateBrushSize() / (brushLayer.size.width / brushCached.size.width)
                let resultLayer = draw(brushSize: brushSize, image: brushCached)
                brushCached = resultLayer
                
                layerImageView.image = brushCached
            } else if sender.state == .ended {
                let brushSize = self.calculateBrushSize()
                
                UIGraphicsBeginImageContextWithOptions(curImage.size, false, 0.0)
                brushLayer.draw(at: .zero)
                for pt in panPathPts {
                    createCirlce(radius: brushSize, color: curColor)!.draw(at: pt.added(with: CGPoint(x: -brushSize / 2, y: -brushSize / 2)))
                }
                brushLayer = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                layerImageView.image = brushLayer
                
                panPathPts = []
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        showPopConfirmation()
    }
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        func failed() {
            self.showErrorMessage(title: R.PE.BRVC.processErrorTitle, message: R.PE.BRVC.processErrorMessage)
            self.dismiss(animated: true, completion: nil)
        }
        
        let loadingVC = LoadingVC.setup(withMessage: R.PE.BRVC.processingMessage)
        curImage.pngquant { (data) in
            if let pngData = data {
                self.curImage.webpData(targetSize: Limits.MaxStickerFileSize) { (data) in
                    if let webpData = data {
                        self.dismiss(animated: true, completion: nil)
                        self.delegate?.pe?(didFinish: webpData, pngData: pngData)
                    } else {
                        printError("Failed to webp the image: data in webpData(targetSize:completion:) is nil.")
                        failed()
                    }
                }
            } else {
                printError("Failed to pngquant the image: data in pngquant(_:) is nil.")
                failed()
            }
        }
        self.present(loadingVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.PE.TagVC.toColorPickerSegueID,
            let dvc = segue.destination as? PEColorPickerVC,
            let color = sender as? UIColor {
            dvc.curColor = color
            dvc.completion = colorPickerCompletion
        }
    }
}
