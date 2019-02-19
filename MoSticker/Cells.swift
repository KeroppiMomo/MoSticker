//
//  TableView Cells.swift
//  MoSticker
//
//  Created by Moses Mok on 29/11/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit

class StickerPackTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noStickerLabel: UILabel!
    @IBOutlet weak var propertyLabel: UILabel!
    
    var images = [UIImage?]()
    var imageTapAction: ((Int) -> (Void))?
    
    func setup(title: String?, detailText: String?, galleryImages: [UIImage?]) {
        titleLabel.text = title
        detailLabel.text = detailText
        images = galleryImages
        
        collectionView.reloadData()
        noStickerLabel.isHidden = images.count != 0
    }
    func setPropertyValue(_ str: String) {
        propertyLabel.text = str
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Resources.Cells.SPackTVC.imageCellID, for: indexPath) as? GalleryImgCollectionViewCell else { return UICollectionViewCell() }
        cell.setup(image: images[indexPath.row])
        cell.imageButton.tag = indexPath.row
        cell.imageButton.removeTarget(nil, action: #selector(tapPressed(_:)), for: .touchUpInside)
        cell.imageButton.addTarget(self, action: #selector(tapPressed(_:)), for: .touchUpInside)
        cell.imageButton.isUserInteractionEnabled = false
        
        return cell
    }
    
    @objc func tapPressed(_ sender: UIButton) {
        imageTapAction?(sender.tag)
    }
    func setIndicatorHidden(_ hidden: Bool, animated: Bool) {
        if animated {
            self.indicatorView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.indicatorView.alpha = hidden ? 0 : 1
            }) { _ in
                self.indicatorView.isHidden = hidden
            }
        } else {
            indicatorView.isHidden = hidden
        }
    }
}
class PropertyEditTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var textFieldLastText = ""
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        textField.delegate = self
    }
    func setup(property: String?, value: String?) {
        titleLabel.text = property
        textFieldLastText = property ?? ""
        textField.placeholder = property
        textField.text = value
    }
    func getValue() -> String {
        return textField.text ?? ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

class ButtonTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    func setup(title: String?) {
        titleLabel.text = title
    }
}

class GalleryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    var images = [UIImage?]()
    var imageTapAction: ((Int) -> (Void))?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    func setup(images: [UIImage?]) {
        self.images = images
        emptyLabel.isHidden = images.count != 0
        collectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Resources.Cells.GalTVC.imageCellID, for: indexPath) as? GalleryImgCollectionViewCell else { return UICollectionViewCell() }
        cell.setup(image: images[indexPath.row])
        cell.imageButton.tag = indexPath.row
        cell.imageButton.removeTarget(nil, action: #selector(tapPressed(_:)), for: .touchUpInside)
        cell.imageButton.addTarget(self, action: #selector(tapPressed(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func tapPressed(_ sender: UIButton) {
        imageTapAction?(sender.tag)
    }
}
class GalleryImgCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageButton: UIButton!
    
    func setup(image: UIImage?) {
        imageButton.setBackgroundImage(image, for: .normal)
        
        imageButton.layer.borderWidth = 1
        imageButton.layer.borderColor = UIColor.lightGray.cgColor
    }
}

class ImageSelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var propertyLabel: UILabel!
    @IBOutlet weak var changeButtonLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    
    func setup(property: String, changeText: String, image: UIImage?) {
        propertyLabel.text = property
        changeButtonLabel.text = changeText
        mainImageView.image = image
        
        mainImageView.layer.borderWidth = 1
        mainImageView.layer.borderColor = UIColor.lightGray.cgColor
    }
}

class ExpandTableViewCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var expandIndicator: UIView!
    
    func setup(isTitle: Bool, isExpanded: Bool, text: String) {
        expandIndicator.isHidden = !isTitle
        expandIndicator.transform = CGAffineTransform(rotationAngle: isExpanded ? CGFloat.pi / 2 : 0)
        mainLabel.text = text
    }
}

class SliderTableViewCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    func setup(text: String, sliderValue: CGFloat) {
        mainLabel.text = text
        slider.value = Float(sliderValue)
    }
}

class BoldHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var buttonLabel: UILabel!
    
    func setup(text: String, buttonText: String) {
        mainLabel.text = text
        buttonLabel.text = buttonText
    }
}
