//
//  PECropVC.swift
//  MoSticker
//
//  Created by Moses Mok on 2/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit

class PECropVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var delegate: PEDelegate?
    
    var resultResolution = 512
    
    var curImage: UIImage!
    var imageScale: CGFloat = 1
    var imageTranslation = CGPoint(x: 0, y: 0)
    
    @IBOutlet weak var highlightView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        highlightView.layer.borderWidth = 1
        highlightView.layer.borderColor = UIColor.lightGray.cgColor
        
        selectSource()
    }
    
    func selectSource() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        let alert = UIAlertController(title: nil, message: R.PE.CroVC.selectSourceMessage, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: R.PE.CroVC.fromCameraMessage, style: .default) { _ in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        let libraryAction = UIAlertAction(title: R.PE.CroVC.fromLibraryMessage, style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: R.Common.cancel, style: .cancel) { _ in
            self.delegate?.peDidCancel?()
        }
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.peDidCancel?()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let scaledImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            UIGraphicsBeginImageContextWithOptions(scaledImage.size.mul(factor: scaledImage.scale), false, 1.0)
            scaledImage.draw(in: CGRect(origin: .zero, size: scaledImage.size.mul(factor: scaledImage.scale)))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            mainImageView.image = image
            curImage = image
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
        let newScale = CGFloat(imageScale) * sender.scale
        if sender.state == .changed {
            mainImageView.transform = CGAffineTransform(translationX: imageTranslation.x, y: imageTranslation.y).scaledBy(x: newScale, y: newScale)
        } else if sender.state == .ended {
            imageScale = newScale
            if imageScale < R.PE.CroVC.minImageScale {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    self.mainImageView.transform = CGAffineTransform(translationX: self.imageTranslation.x, y: self.imageTranslation.y).scaledBy(x: R.PE.CroVC.minImageScale, y: R.PE.CroVC.minImageScale)
                }) { _ in
                    self.imageScale = R.PE.CroVC.minImageScale
                }
            }
        }
    }
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let newTranslation = sender.translation(in: view).added(with: imageTranslation)
        if sender.state == .changed {
            mainImageView.transform = CGAffineTransform(translationX: newTranslation.x, y: newTranslation.y).scaledBy(x: imageScale, y: imageScale)
        } else if sender.state == .ended {
            imageTranslation = newTranslation
        }
    }
    
    @IBAction func nextPressed(_ sender: UIBarButtonItem) {
        if let img = cropImage() {
            performSegue(withIdentifier: R.PE.CroVC.toBackRemoveSegueID, sender: img)
        } else {
            printError("Failed to crop image: cropImage() returns nil.")
        }
    }
    
    func cropImage() -> UIImage? {
        let tfedOrigin = mainImageView.tfedOrigin.sub(with: CGPoint(x: 0, y: self.calculateTopDistance()))
        let tfedSize = mainImageView.tfedSize

        let imgSize = curImage.size
        let oriImgViewSize = mainImageView.frame

        
        let imgScreenRect: CGRect
        if oriImgViewSize.width / oriImgViewSize.height < imgSize.width / imgSize.height {
            let imgScreenSize = CGSize(width: tfedSize.width, height: imgSize.height / imgSize.width * tfedSize.width)
            let imgScreenPosition = CGPoint(x: tfedOrigin.x, y: tfedOrigin.y + (tfedSize.height - imgScreenSize.height) / 2.0)

            imgScreenRect = CGRect(origin: imgScreenPosition, size: imgScreenSize)
        } else {
            let imgScreenSize = CGSize(width: imgSize.width / imgSize.height * tfedSize.height, height: tfedSize.height)
            let imgScreenPosition = CGPoint(x: tfedOrigin.x + (tfedSize.width - imgScreenSize.width) / 2.0, y: tfedOrigin.y)
            
            imgScreenRect = CGRect(origin: imgScreenPosition, size: imgScreenSize)
        }
        
        let left = fractionInRange(min: 0, width: highlightView.frame.width, x: imgScreenRect.minX)
        let right = fractionInRange(min: 0, width: highlightView.frame.width, x: imgScreenRect.maxX)
        let top = fractionInRange(min: highlightView.frame.minY - self.calculateTopDistance(), max: highlightView.frame.maxY - self.calculateTopDistance(), x: imgScreenRect.minY)
        let bottom = fractionInRange(min: highlightView.frame.minY - self.calculateTopDistance(), max: highlightView.frame.maxY - self.calculateTopDistance(), x: imgScreenRect.maxY)
        
        let croppingRect = CGRect(x: left, y: top, width: right - left, height: bottom - top).mul(factor: CGFloat(resultResolution))
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: resultResolution, height: resultResolution), false, 1.0)
        UIColor.clear.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: resultResolution, height: resultResolution))
        curImage.draw(in: croppingRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        delegate?.peDidCancel?()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.PE.CroVC.toBackRemoveSegueID,
            let dvc = segue.destination as? PEBackRemoveVC,
            let image = sender as? UIImage {
            dvc.curImage = image
            dvc.delegate = self.delegate
        }
    }
}

