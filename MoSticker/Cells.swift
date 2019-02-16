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
    
    var images = [UIImage?]()
    var imageTapAction: ((Int) -> (Void))?
    
    func setup(title: String?, detailText: String?, galleryImages: [UIImage?]) {
        titleLabel.text = title
        detailLabel.text = detailText
        images = galleryImages
        
        collectionView.reloadData()
        noStickerLabel.isHidden = images.count != 0
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

//class GalleryTableViewCell: UITableViewCell {
//    var imageTapAction: ((Int) -> (Void))?
//
//    @IBOutlet weak var stackView: UIStackView!
//    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapPressed(_:)))
//
//    func setup(images: [UIImage]) {
//        func createOffsetView() -> UIView {
//            let view = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: self.frame.height - 16))
//            view.backgroundColor = UIColor(r: 0, 0, 0, 0)
//            return view
//        }
//
//        tapRecognizer.delegate = self
//
//        stackView.arrangedSubviews.forEach({stackView.removeArrangedSubview($0)})
//
//        var i = 0
//        stackView.addArrangedSubview(createOffsetView())
//        for img in images {
//            let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.height - 16, height: self.frame.height - 16))
//            button.heightAnchor.constraint(equalToConstant: self.frame.height - 16).isActive = true
//            button.widthAnchor.constraint(equalToConstant: self.frame.height - 16).isActive = true
//            button.tag = i
//            button.setBackgroundImage(img, for: .normal)
//            button.addTarget(self, action: #selector(tapPressed(_:)), for: .touchUpInside)
//
//            stackView.addArrangedSubview(button)
//
//            i += 1
//        }
//
//        stackView.addArrangedSubview(createOffsetView())
//    }
//    @objc func tapPressed(_ sender: UIButton) {
//        imageTapAction?(sender.tag)
//    }
//}
class GalleryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    var images = [UIImage?]()
    var imageTapAction: ((Int) -> (Void))?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
//    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapPressed(_:)))
    
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
