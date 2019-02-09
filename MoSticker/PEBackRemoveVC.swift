//
//  PEBackRemoveVC.swift
//  MoSticker
//
//  Created by Moses Mok on 8/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit

func createCirlce(radius: CGFloat, color: UIColor) -> UIImage? {
    let rect = CGRect(x: 0, y: 0, width: radius, height: radius)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    let ctx = UIGraphicsGetCurrentContext()
    ctx!.setFillColor(color.cgColor)
    ctx!.fillEllipse(in: rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

class PEBackRemoveVC: UIViewController, UIScrollViewDelegate, UIToolbarDelegate {
    
    var curImage: UIImage!
    var cachedImg: UIImage!
    var maskImage: UIImage!
    var maskCachedImage: UIImage!

    var delegate: PEDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: PanningImageView!
    @IBOutlet weak var allowScrollBarButton: UIBarButtonItem!
    @IBOutlet weak var allowIncludeBarButton: UIBarButtonItem!
    @IBOutlet weak var allowExcludeBarButton: UIBarButtonItem!
    @IBOutlet weak var brushSizeSlider: UISlider!
    @IBOutlet weak var brushPreviewView: UIView!
    @IBOutlet weak var brushPreviewSizeConstraint: NSLayoutConstraint!
    
    var _modeIndex = 0
    var modeIndex: Int {
        get { return _modeIndex }
        set {
            _modeIndex = newValue
            
            allowScrollBarButton.image = R.PE.BRVC.disableScrollIcon
            allowIncludeBarButton.image = R.PE.BRVC.disableIncludeIcon
            allowExcludeBarButton.image = R.PE.BRVC.disableExcludeIcon
            scrollView.isScrollEnabled = false
            scrollView.pinchGestureRecognizer?.isEnabled = false

            switch modeIndex {
            case 0:
                allowScrollBarButton.image = R.PE.BRVC.enableScrollIcon
                scrollView.isScrollEnabled = true
                scrollView.pinchGestureRecognizer?.isEnabled = true
            case 1:
                allowIncludeBarButton.image = R.PE.BRVC.enableIncludeIcon
            case 2:
                allowExcludeBarButton.image = R.PE.BRVC.enableExcludeIcon
            default:
                printError("Unknown index: newValue is \(newValue).")
            }
        }
    }
    
    var lastScrollZoom: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = curImage
        
        UIGraphicsBeginImageContextWithOptions(curImage.size, true, 0.0)
        UIColor.black.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: curImage.size))
        maskImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cachedSize = CGSize(width: R.PE.cachedImgRes, height: R.PE.cachedImgRes)
        UIGraphicsBeginImageContextWithOptions(cachedSize, true, 0.0)
        UIColor.black.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: cachedSize))
        maskCachedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        UIGraphicsBeginImageContextWithOptions(cachedSize, false, 0.0)
        curImage.draw(in: CGRect(origin: .zero, size: cachedSize))
        cachedImg = UIGraphicsGetImageFromCurrentImageContext()
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
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .bottom
    }
    
    func calculateBrushSize() -> CGFloat {
        let sliderValue = brushSizeSlider.value
        let maxBrushSize = curImage.size.width / scrollView.zoomScale / 4
        let minBrushSize = curImage.size.width / scrollView.zoomScale / 100
        return minBrushSize + CGFloat(sliderValue) * (maxBrushSize - minBrushSize)
    }
    
    @IBAction func sizeSliderChanged(_ sender: UISlider) {
        brushPreviewView.isHidden = false
        
        let brushSize = calculateBrushSize()
        let sizeToScreen = brushSize / curImage.size.width * view.frame.width
        let previewSize = sizeToScreen * scrollView.zoomScale
        brushPreviewSizeConstraint.constant = previewSize
        brushPreviewView.layer.cornerRadius = previewSize / 2
    }
    @IBAction func sizeSliderEnded(_ sender: UISlider) {
        brushPreviewView.isHidden = true
    }
    @IBAction func modeBarButtonPressed(_ sender: UIBarButtonItem) {
        switch sender {
        case allowScrollBarButton:
            modeIndex = 0
        case allowIncludeBarButton:
            modeIndex = 1
        case allowExcludeBarButton:
            modeIndex = 2
        default:
            printError("Unknown sender: sender is \(sender).")
        }
    }
    
    var panPathPts = [(CGPoint, CGFloat)]()
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        if modeIndex != 0,
           let startingPoint = imageView.panningStartPoint {
            func mask(brushSize: CGFloat, sourceImg: UIImage, maskImg: UIImage) -> (img: UIImage, mask: UIImage) {
                let resultMask: UIImage!
                let resultImg: UIImage!
                
                let touchingPoint = startingPoint.added(with: sender.translation(in: imageView))
                let pointOnImg = touchingPoint.mul(factor: maskImg.size.width / view.frame.width)
                panPathPts.append((pointOnImg.mul(factor: curImage.size.width / cachedImg.size.width), brushSize * (curImage.size.width / cachedImg.size.width)))
                
                let maskColor = self.modeIndex == 1 ? UIColor.black : UIColor.white
                UIGraphicsBeginImageContextWithOptions(maskImg.size, false, 0.0)
                maskImg.draw(in: CGRect(origin: CGPoint.zero, size: maskImg.size))
                
                createCirlce(radius: brushSize, color: maskColor)!.draw(at: pointOnImg.added(with: CGPoint(x: -brushSize / 2, y: -brushSize / 2)))
                resultMask = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                UIGraphicsBeginImageContextWithOptions(sourceImg.size, false, 0.0)
                resultMask.draw(in: CGRect(origin: .zero, size: sourceImg.size))
                let resizedMask = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                if let maskedImage = imageMasking(sourceImg, maskImage: resizedMask) {
                    resultImg = maskedImage
                } else {
                    printError("Masking fail: imageMasking(_:maskImage:) returns nil")
                    resultImg = sourceImg
                }
                
                return (resultImg, resultMask)
            }
            
            if sender.state == .changed {
                let brushSize = self.calculateBrushSize() / (maskImage.size.width / cachedImg.size.width)
                let (resultImg, resultMask) = mask(brushSize: brushSize, sourceImg: cachedImg, maskImg: maskCachedImage)
                maskCachedImage = resultMask
                
                self.imageView.image = resultImg
            } else if sender.state == .ended {
                let maskColor = self.modeIndex == 1 ? UIColor.black : UIColor.white

                UIGraphicsBeginImageContextWithOptions(curImage.size, false, 0.0)
                maskImage.draw(at: .zero)
                for (pt, brushSize) in panPathPts {
                    createCirlce(radius: brushSize, color: maskColor)!.draw(at: pt.added(with: CGPoint(x: -brushSize / 2, y: -brushSize / 2)))
                }
                maskImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                if let maskedImage = imageMasking(curImage, maskImage: maskImage) {
                    imageView.image = maskedImage
                } else {
                    printError("Masking fail: imageMasking(_:maskImage:) returns nil")
                }
                
                panPathPts = []
            }
            
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        showPopConfirmation()
    }
    
    @IBAction func nextPressed(_ sender: UIBarButtonItem) {
        if let resultImg = imageMasking(curImage, maskImage: maskImage) {
            self.performSegue(withIdentifier: R.PE.BRVC.toTagSegueID, sender: resultImg)
        } else {
            printError("Masking failed: imageMasking(_:maskImage:) returns nil.")
            self.showErrorMessage(title: R.PE.BRVC.processErrorTitle, message: R.PE.BRVC.processErrorMessage)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.PE.BRVC.toTagSegueID,
            let dvc = segue.destination as? PETaggingVC,
            let image = sender as? UIImage {
            
            dvc.curImage = image
            dvc.delegate = self.delegate
        }
    }
}
