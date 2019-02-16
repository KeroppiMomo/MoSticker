//
//  PETaggingVC.swift
//  MoSticker
//
//  Created by Moses Mok on 13/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit

class PETaggingVC: UIViewController, UIScrollViewDelegate {
    enum UndoAction {
        case emojis
        case brush
        case color
    }
    struct EmojiElement {
        var emoji: String
        var position: CGPoint
        var fontSize: CGFloat = 120
        var rotationRadian: CGFloat = 0
        
        init(emoji: String, position: CGPoint) {
            self.emoji = emoji
            self.position = position
        }
        
        func scale(factor: CGFloat) -> EmojiElement {
            var ee = EmojiElement(emoji: self.emoji, position: self.position.mul(factor: factor))
            ee.fontSize = self.fontSize * factor
            ee.rotationRadian = self.rotationRadian
            
            return ee
        }
    }
    
    
    var delegate: PEDelegate?
    var curImage: UIImage!
    var brushCached: UIImage!
    
    var _brushLayer: UIImage!
    var brushLayer: UIImage! {
        get { return _brushLayer }
        set {
            undoHistory.append((type: .brush, obj: _brushLayer))
            _brushLayer = newValue
        }
    }
    
    var _curColor = UIColor.red
    var curColor: UIColor {
        get { return _curColor }
        set {
            undoHistory.append((type: .color, obj: _curColor))
            _curColor = newValue
            curColorButton.backgroundColor = curColor
        }
    }
    
    var _undoHistory = [(type: UndoAction, obj: Any)]()
    var undoHistory: [(type: UndoAction, obj: Any)] {
        get { return _undoHistory }
        set {
            _undoHistory = newValue
            undoButton.isEnabled = newValue.count != 0
        }
    }
    
    private var _emojiEls = [EmojiElement]()
    var emojiEls: [EmojiElement] { // El stands for Element
        get { return _emojiEls }
        set {
            undoHistory.append((type: .emojis, obj: _emojiEls))
            _emojiEls = newValue
            updateEmojiView()
        }
    }
    
    
    @IBOutlet weak var imageView: PanningImageView!
    @IBOutlet weak var layerImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var allowScrollButton: UIBarButtonItem!
    @IBOutlet weak var brushButton: UIBarButtonItem!
    @IBOutlet weak var curColorButton: UIButton!
    @IBOutlet weak var emojiLayerView: UIView!

    var _modeIndex = 0
    var modeIndex: Int {
        get { return _modeIndex }
        set {
            _modeIndex = newValue
            
            allowScrollButton.image = R.PE.TagVC.disableScrollIcon
            brushButton.image = R.PE.TagVC.disableBrushIcon
            scrollView.isScrollEnabled = false
            scrollView.pinchGestureRecognizer?.isEnabled = false
            emojiLayerView.isUserInteractionEnabled = false

            switch _modeIndex {
            case 0:
                allowScrollButton.image = R.PE.TagVC.enableScrollIcon
                scrollView.isScrollEnabled = true
                scrollView.pinchGestureRecognizer?.isEnabled = true
                emojiLayerView.isUserInteractionEnabled = true
            case 1:
                brushButton.image = R.PE.TagVC.enableBrushIcon
            default:
                printError("Unknown index: newValue is \(newValue).")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = curImage
        
        UIGraphicsBeginImageContextWithOptions(curImage.size, false, 1.0)
        brushLayer = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cachedSize = CGSize(width: R.PE.cachedImgRes, height: R.PE.cachedImgRes)
        
        UIGraphicsBeginImageContextWithOptions(cachedSize, false, 1.0)
        brushCached = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        undoHistory = []
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let topDistance = self.calculateTopDistance()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 2 * topDistance, right: 0)
        scrollView.zoomScale = 1
    }
    
    func updateEmojiView() {
        emojiLayerView.subviews.forEach { $0.removeFromSuperview() } // Remove all subviews
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(emojiPinchGesture(_:)))
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(emojiTapGesture(_:)))
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(emojiPanGesture(_:)))
        let rotateGR = UIRotationGestureRecognizer(target: self, action: #selector(emojiRotationGesture(_:)))
        for i in 0..<emojiEls.count {
            let emojiEl = emojiEls[i]
            let label = UILabel()
            emojiLayerView.addSubview(label) // To work with sizeToFit()

            label.text = emojiEl.emoji
            label.font = UIFont.systemFont(ofSize: emojiEl.fontSize)
            label.sizeToFit()
            label.frame = CGRect(origin: emojiEl.position.sub(with: CGPoint(x: label.bounds.width / 2, y: label.bounds.height / 2)), size: label.bounds.size)
            label.transform = CGAffineTransform(rotationAngle: emojiEl.rotationRadian)
            label.tag = i
            
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(pinchGR)
            label.addGestureRecognizer(tapGR)
            label.addGestureRecognizer(panGR)
            label.addGestureRecognizer(rotateGR)
        }
    }
    @objc func emojiPinchGesture(_ sender: UIPinchGestureRecognizer) {
        guard let emojiView = sender.view else { return }
        let scale = sender.scale
        let transform = CGAffineTransform(scaleX: scale, y: scale).rotated(by: emojiEls[emojiView.tag].rotationRadian)
        if sender.state == .changed {
            emojiView.transform = transform

        } else if sender.state == .ended {
            emojiEls[emojiView.tag].fontSize = emojiEls[emojiView.tag].fontSize * scale
            updateEmojiView()
        }
    }
    @objc func emojiTapGesture(_ sender: UITapGestureRecognizer) {
        guard let emojiView = sender.view else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let removeAction = UIAlertAction(title: R.PE.TagVC.removeEmojiMessage, style: .destructive) { _ in
            
            UIView.animate(withDuration: R.PE.TagVC.removeEmojiAnimationInterval, animations: {
                emojiView.alpha = 0
            }) { _ in
                self.emojiEls.remove(at: emojiView.tag)
            }
        }
        let cancelAction = UIAlertAction(title: R.Common.cancel, style: .cancel, handler: nil)
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    @objc func emojiPanGesture(_ sender: UIPanGestureRecognizer) {
        guard let emojiView = sender.view else { return }
        let translation = sender.translation(in: emojiView)
        let transform = CGAffineTransform(rotationAngle: emojiEls[emojiView.tag].rotationRadian).translatedBy(x: translation.x, y: translation.y)
        if sender.state == .changed {
            emojiView.transform = transform
        } else if sender.state == .ended {
            emojiEls[emojiView.tag].position = CGPoint(x: transform.tx, y: transform.ty).added(with: emojiEls[emojiView.tag].position)
            updateEmojiView()
        }
    }
    @objc func emojiRotationGesture(_ sender: UIRotationGestureRecognizer) {
        guard let emojiView = sender.view else { return }
        let rotation = sender.rotation
        if sender.state == .changed {
            emojiView.transform = CGAffineTransform(rotationAngle: rotation + emojiEls[emojiView.tag].rotationRadian)
        } else if sender.state == .ended {
            emojiEls[emojiView.tag].rotationRadian = rotation + emojiEls[emojiView.tag].rotationRadian
            updateEmojiView()
        }
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
        default:
            print("Unknown sender: sender is \(sender).")
        }
    }
    @IBAction func undoButtonPressed(_ sender: UIBarButtonItem) {
        guard let (type, obj) = undoHistory.last else { return }
        switch type {
        case .emojis:
            guard let emojis = obj as? [EmojiElement] else { return }
            _emojiEls = emojis
            updateEmojiView()
            break
        case .color:
            guard let color = obj as? UIColor else { return }
            _curColor = color
            curColorButton.backgroundColor = curColor
            break
        case .brush:
            guard let layer = obj as? UIImage else { return }
            _brushLayer = layer
            layerImageView.image = brushLayer
            
            UIGraphicsBeginImageContextWithOptions(brushCached.size, false, 1.0)
            brushLayer.draw(in: CGRect(origin: .zero, size: brushCached.size))
            brushCached = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            break
        }
        undoHistory.removeLast()
    }
    @IBAction func emojiPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: R.PE.TagVC.toEmojiSegueID, sender: nil)
    }
    @IBAction func colorPressed(_ sender: UIButton) {
        performSegue(withIdentifier: R.PE.TagVC.toColorPickerSegueID, sender: curColor)
    }
    func colorPickerCompletion(_ color: UIColor) {
        curColor = color
        self.dismiss(animated: true, completion: nil)
    }
    func emojiPickerCompletion(_ emoji: String) {
        let emojiEl = EmojiElement(emoji: emoji, position: CGPoint(x: emojiLayerView.bounds.midX, y: emojiLayerView.bounds.midY))
        emojiEls.append(emojiEl)
        self.dismiss(animated: true, completion: nil)
        modeIndex = 0
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
                
                UIGraphicsBeginImageContextWithOptions(image.size, false, 1.0)
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
                
                UIGraphicsBeginImageContextWithOptions(curImage.size, false, 1.0)
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
        
        let ratioImgToScreen = curImage.size.width / imageView.bounds.width
        let emojisInImg = emojiEls.map { $0.scale(factor: ratioImgToScreen) }
        
        UIGraphicsBeginImageContextWithOptions(curImage.size, false, 1.0)
        curImage.draw(at: .zero)
        brushLayer.draw(at: .zero)
        for emojiEl in emojisInImg {
            
            let textSize: CGSize = {
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: emojiEl.fontSize)
                label.text = emojiEl.emoji
                label.sizeToFit()
                return label.bounds.size
            }()
            
            UIGraphicsBeginImageContextWithOptions(textSize, false, 1.0)
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: emojiEl.fontSize)
            ]
            let attributedStr = NSAttributedString(string: emojiEl.emoji, attributes: attributes)
            
            attributedStr.draw(in: CGRect(origin: .zero, size: textSize))
            let imageWithText = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let rotatedText = imageWithText!.rotate(radians: emojiEl.rotationRadian)!
            
            let drawingPoint = CGPoint(x: emojiEl.position.x - rotatedText.size.width / 2, y: emojiEl.position.y - rotatedText.size.height / 2)

            rotatedText.draw(at: drawingPoint)
        }
        
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let progressVC = ProgressVC.setup(withMessage: R.PE.BRVC.processingMessage)

        let group = DispatchGroup()
        var pngData: Data?
        var webpData: Data?
        var pngProgress: Float = 0
        var webpProgress: Float = 0
        
        func failed() {
            self.showErrorMessage(title: R.PE.BRVC.processErrorTitle, message: R.PE.BRVC.processErrorMessage)
            self.dismiss(animated: true, completion: nil)
        }
        func updateProgress() {
            progressVC.update(progress: (pngProgress + webpProgress * 2) / 3)
        }

        group.enter()
        outputImage.pngquant(progressHandler: { progress in
            pngProgress = progress
            updateProgress()
        }) { (data) in
            if let data = data {
                pngData = data
                pngProgress = 1.0
                updateProgress()
                
                group.leave()
            } else {
                printError("Failed to pngquant the image: data in pngquant(_:) is nil.")
                failed()
            }
        }
        group.enter()
        outputImage.webpData(targetSize: Limits.MaxStickerFileSize, progressHandler: { progress in
            webpProgress = progress
            updateProgress()
        }) { (data) in
            if let data = data {
                webpData = data
                webpProgress = 1.0
                updateProgress()
                
                group.leave()
            } else {
                printError("Failed to webp the image: data in webpData(targetSize:completion:) is nil.")
                failed()
            }
        }
        
        group.notify(queue: .main) {
            self.dismiss(animated: true, completion: nil)
            self.delegate?.pe?(didFinish: webpData!, pngData: pngData!)
        }
        self.present(progressVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.PE.TagVC.toColorPickerSegueID,
            let dvc = segue.destination as? PEColorPickerVC,
            let color = sender as? UIColor {
            dvc.curColor = color
            dvc.completion = colorPickerCompletion
        } else if segue.identifier == R.PE.TagVC.toEmojiSegueID,
            let dvc = segue.destination as? PEEmojiSelectVC {
            dvc.completion = emojiPickerCompletion
        }
    }
}
