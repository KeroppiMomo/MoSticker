//
//  PECropScroll.swift
//  MoSticker
//
//  Created by Moses Mok on 4/2/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

fileprivate typealias R = Resources.PE.CroSVC
class PECropScrollVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    
    // MARK: - Variable Declaration
    var resultResolution = 512
    
    var curImage: UIImage!
    var delegate: PEDelegate?
    
    // MARK: - IBOutlet Declaration
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cropWindowView: UIView!
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()

        selectSource()
    }
    
    func selectSource() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        let alert = UIAlertController(title: nil, message: R.selectSourceMessage, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: R.fromCameraMessage, style: .default) { _ in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        let libraryAction = UIAlertAction(title: R.fromLibraryMessage, style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: Rc.cancel, style: .cancel) { _ in
            self.delegate?.peDidCancel?()
        }
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(scrollView.contentOffset, animated: true)
    }
    func zoomFocus() {
        scrollView.zoom(to: mainImageView.frame, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
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
            
            zoomFocus()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Other Functions
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        delegate?.peDidCancel?()
    }
    @IBAction func nextPressed(_ sender: UIBarButtonItem) {
        guard let image = cropImage() else {
            self.showErrorMessage(title: R.cropErrorTitle, message: R.cropErrorMessage)
            printError("cropImage() returns nil")
            return
        }
        
        performSegue(withIdentifier: R.toBackRemoveSegueID, sender: image)
    }
    
    func aspectFittedRect(frame: CGSize, content: CGSize) -> CGRect {
        let xScale = content.width / frame.width
        let yScale = content.height / frame.height
        
        if xScale > yScale {
            let contentSizeInFrame = content.mul(factor: frame.width / content.width)
            return CGRect(x: 0, y: (frame.height - contentSizeInFrame.height) / 2, width: frame.width, height: contentSizeInFrame.height)
        } else {
            let contentSizeInFrame = content.mul(factor: frame.height / content.height)
            return CGRect(x: (frame.width - contentSizeInFrame.width) / 2, y: 0, width: contentSizeInFrame.width, height: frame.height)
        }
    }
    func cropImage() -> UIImage? {
        let imageViewRect = mainImageView.convert(mainImageView.bounds, to: nil)
        let aspectFitted = aspectFittedRect(frame: imageViewRect.size, content: curImage.size).add(with: imageViewRect.origin)
        let imageRect = aspectFitted.add(with: cropWindowView.frame.origin.mul(factor: -1))
        let cropWindowRect = cropWindowView.frame
        
        let left = fractionInRange(min: 0, width: cropWindowRect.width, x: imageRect.minX)
        let right = fractionInRange(min: 0, width: cropWindowRect.width, x: imageRect.maxX)
        let top = fractionInRange(min: 0, max: cropWindowRect.height, x: imageRect.minY)
        let bottom = fractionInRange(min: 0, max: cropWindowRect.height, x: imageRect.maxY)
        
        let croppingRect = CGRect(x: left, y: top, width: right - left, height: bottom - top).mul(factor: CGFloat(resultResolution))
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: resultResolution, height: resultResolution), false, 1.0)
        UIColor.clear.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: resultResolution, height: resultResolution))
        curImage.draw(in: croppingRect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.toBackRemoveSegueID,
            let dvc = segue.destination as? PEBackRemoveVC,
            let image = sender as? UIImage {
            dvc.curImage = image
            dvc.delegate = self.delegate
        }
    }
}
