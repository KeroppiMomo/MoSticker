//
//  Helper.swift
//  MoSticker
//
//  Created by Moses Mok on 29/11/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit
import Foundation
import YYImage
import FirebaseAuth
import Crashlytics

func fractionInRange(min: CGFloat, max: CGFloat, x: CGFloat) -> CGFloat {
    return (x - min) / (max - min)
}
func fractionInRange(min: CGFloat, width: CGFloat, x: CGFloat) -> CGFloat {
    return (x - min) / width
}

func getAppVersion() -> String? {
    guard let dict = Bundle.main.infoDictionary else { return nil }
    return dict["CFBundleShortVersionString"] as? String
}

func printError(_ message: Any, file: String = #file, recordCrashlytics: Bool = true, function: String = #function, line: Int = #line, column: Int = #column) {
    let filename = (file as NSString).lastPathComponent
    print("\n‼️‼️‼️‼️‼️‼️ ERROR \n'\(message)'\n@ \(filename) \(line):\(column) \(function)\n‼️‼️‼️‼️‼️‼️\n")
    
    if recordCrashlytics {
        if let error = message as? Error {
            Crashlytics.sharedInstance().recordError(error)
        } else {
            Crashlytics.sharedInstance().recordCustomExceptionName(String(describing: message), reason: "\(filename) \(line):\(column) \(function)", frameArray: [])
        }
    }
}
func printWarning(_ message: Any, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
    let filename = (file as NSString).lastPathComponent
    print("\n⚠️⚠️⚠️⚠️⚠️⚠️ WARNING \n'\(message)'\n@ \(filename) \(line):\(column) \(function)\n⚠️⚠️⚠️⚠️⚠️⚠️\n")
}
func printInfo(_ message: Any, file: String = #file, function: String = #function, line: Int = #line, column: Int = #column) {
    let filename = (file as NSString).lastPathComponent
    print("\nℹ️ℹ️ℹ️ℹ️ℹ️ℹ️ INFO \n'\(message)'\n@ \(filename) \(line):\(column) \(function)\nℹ️ℹ️ℹ️ℹ️ℹ️ℹ️\n")
}

func ownershipDescription(name: String?, id: String) -> String {
    return (name ?? Resources.Common.noOwnerNameMessage) + (id == Auth.auth().currentUser?.uid ? Resources.Common.ownedMessage : "")
}

func imageMasking(_ originalImg: UIImage, maskImage: UIImage) -> UIImage? {
    let cgMaskImage = maskImage.cgImage!
    let cgOriImage = originalImg.cgImage!
    let mask = CGImage(maskWidth: cgMaskImage.width, height: cgMaskImage.height, bitsPerComponent: cgMaskImage.bitsPerComponent, bitsPerPixel: cgMaskImage.bitsPerPixel, bytesPerRow: cgMaskImage.bytesPerRow, provider: cgMaskImage.dataProvider!, decode: nil, shouldInterpolate: true)!
    guard let masked = cgOriImage.masking(mask) else { return nil }
    
    UIGraphicsBeginImageContextWithOptions(originalImg.size, false, 1)
    UIImage(cgImage: masked).draw(in: CGRect(origin: .zero, size: originalImg.size))
    let result = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return result
}


func createLabelView(_ text: String) -> UIView {
    let label = UILabel()
    label.text = text
    label.textAlignment = .center
    label.numberOfLines = 0
    label.backgroundColor = UIColor(r: 239, 239, 244, 1.0)
    label.textColor = .lightGray
    return label
}
func createLoadingBackgroundView() -> UIView {
    let backgroundView = UIView()
    
    let indicator = UIActivityIndicatorView(style: .gray)
    indicator.isHidden = false
    indicator.startAnimating()
    indicator.translatesAutoresizingMaskIntoConstraints = false
    
    backgroundView.addSubview(indicator)
    
    NSLayoutConstraint(item: backgroundView, attribute: .centerX, relatedBy: .equal, toItem: indicator, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
    NSLayoutConstraint(item: backgroundView, attribute: .centerY, relatedBy: .equal, toItem: indicator, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
    
    return backgroundView
}

extension UIColor {
    convenience init(r int: Int, _ g: Int, _ b: Int, _ a: Double) {
        self.init(red: CGFloat(int) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a))
    }
}

extension CGPoint {
    func added(with point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + point.x, y: self.y + point.y)
    }
    func sub(with point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x - point.x, y: self.y - point.y)
    }
    func mul(factor: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * factor, y: self.y * factor)
    }
}
extension CGSize {
    func mul(factor: CGFloat) -> CGSize {
        return CGSize(width: self.width * factor, height: self.height * factor)
    }
}
extension CGRect {
    func mul(factor: CGFloat) -> CGRect {
        return CGRect(x: self.minX * factor, y: self.minY * factor, width: self.width * factor, height: self.height * factor)
    }
    mutating func muled(factor: CGFloat) {
        self = self.mul(factor: factor)
    }
    func add(with point: CGPoint) -> CGRect {
        return CGRect(x: self.minX + point.x, y: self.minY + point.y, width: self.width, height: self.height)
    }
}

extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        get {
            guard let color = self.layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
    @IBInspectable var borderWidth: CGFloat {
        get { return self.layer.borderWidth }
        set { self.layer.borderWidth = newValue }
    }
    @IBInspectable var cornerRadius: CGFloat {
        get { return self.layer.cornerRadius }
        set { self.layer.cornerRadius = newValue }
    }
    @IBInspectable var shadowColor: UIColor? {
        get {
            guard let color = self.layer.shadowColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
    }
    @IBInspectable var shadowOpacity: CGFloat {
        get { return CGFloat(self.layer.shadowOpacity) }
        set { self.layer.shadowOpacity = Float(newValue) }
    }
    @IBInspectable var shadowRadius: CGFloat {
        get { return self.layer.shadowRadius }
        set { self.layer.shadowRadius = newValue }
    }
    
    /// Helper to get pre transform frame
    var originalFrame: CGRect {
        let currentTransform = transform
        transform = .identity
        let originalFrame = frame
        transform = currentTransform
        return originalFrame
    }
    
    /// Helper to get point offset from center
    func centerOffset(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - center.x, y: point.y - center.y)
    }
    
    /// Helper to get point back relative to center
    func pointRelativeToCenter(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x + center.x, y: point.y + center.y)
    }
    
    /// Helper to get point relative to transformed coords
    func newPointInView(_ point: CGPoint) -> CGPoint {
        // get offset from center
        let offset = centerOffset(point)
        // get transformed point
        let transformedPoint = offset.applying(transform)
        // make relative to center
        return pointRelativeToCenter(transformedPoint)
    }
    
    /// Get the transformed frame origin.
    var tfedOrigin: CGPoint {
        return newPointInView(originalFrame.origin)
    }
    
    /// Get the transformed frame size.
    var tfedSize: CGSize {
        var point = originalFrame.origin
        point.x += originalFrame.width
        point.y += originalFrame.height
        let tfedCorner = newPointInView(point)
        
        let sizePoint = tfedCorner.sub(with: newPointInView(originalFrame.origin))
        return CGSize(width: sizePoint.x, height: sizePoint.y)
    }
}

extension UIViewController {
    
    
    /// Calculate top distance with "navigationBar" and "statusBar" by adding a
    /// subview constraint to navigationBar or to topAnchor or superview
    /// - Returns: The real distance between topViewController and Bottom navigationBar
    func calculateTopDistance() -> CGFloat{
        
        /// Create view for misure
        let misureView : UIView     = UIView()
        misureView.backgroundColor  = .clear
        view.addSubview(misureView)
        
        /// Add needed constraint
        misureView.translatesAutoresizingMaskIntoConstraints                    = false
        misureView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive     = true
        misureView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive   = true
        misureView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        if let nav = navigationController {
            misureView.topAnchor.constraint(equalTo: nav.navigationBar.bottomAnchor).isActive = true
        }else{
            misureView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        
        /// Force layout
        view.layoutIfNeeded()
        
        /// Calculate distance
        let distance = view.frame.size.height - misureView.frame.size.height
        
        /// Remove from superview
        misureView.removeFromSuperview()
        
        return distance
        
    }
    
    func showPopConfirmation() {
        let CANCEL_ALERT_TITLE = "Changes will not be saved."
        let CANCEL_ALERT_CONTINUE_TEXT = "Continue Editing"
        let CANCEL_ALERT_BACK_TEXT = "Back to Previous Page"

        let alert = UIAlertController(title: nil, message: CANCEL_ALERT_TITLE, preferredStyle: .alert)
        let continueAction = UIAlertAction(title: CANCEL_ALERT_CONTINUE_TEXT, style: .default, handler: nil)
        let backAction = UIAlertAction(title: CANCEL_ALERT_BACK_TEXT, style: .destructive) { _ in
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(continueAction)
        alert.addAction(backAction)
        
        present(alert, animated: true, completion: nil)
    }
    func showErrorMessage(title: String?, message: String?, _ completion: @escaping () -> Void = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Resources.Common.ok, style: .default, handler: { _ in
            completion()
        })
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showWhatsAppError(error: Error) {
        switch error {
        case WhatsAppPackError.whatsAppUnavailable:
            self.showErrorMessage(title: "Error: WhatsApp Unavailable", message: "Failed to send sticker pack to WhatsApp. Please check whether WhatsApp is installed and activated.")
        case let WhatsAppPackError.fieldEmptyError(field: field):
            self.showErrorMessage(title: "Error: Empty Property", message: "Failed to create sticker pack. '\(field)' must not be empty.")
        case let WhatsAppPackError.fieldCharCountError(field: field, count: count, max: max):
            self.showErrorMessage(title: "Error: Too Many Characters", message: "Failed to create sticker pack. '\(field)' must be less than \(max) characters, but it currently has \(count) character\(count != 1 ? "s" : "").")
        case WhatsAppPackError.trayImagePNGError:
            self.showErrorMessage(title: "Error: Icon PNG Generation", message: "Failed to create sticker pack. The tray image cannot be generated a PNG file.")
        case let WhatsAppPackError.stickerNoError(count: count):
            self.showErrorMessage(title: "Error: Sticker Number Outside Allowable Range", message: "Failed to create sticker pack. A sticker pack must have at least 1 stickers and at most 30 stickers, but it currently has \(count) sticker\(count != 1 ? "s" : "").")
        case StickerPackError.animatedImagesNotSupported:
            self.showErrorMessage(title: "Error: Animated Images Not Supported", message: "Failed to create sticker pack. Stickers or pack icon must not be an animated images.")
        case let StickerPackError.imageTooBig(size):
            self.showErrorMessage(title: "Error: Image Too Big", message: "Failed to create sticker pack. A sticker or the pack icon has a size of \(size) bytes, which is too big.")
        default:
            self.showErrorMessage(title: "Unknown Error", message: "Failed to create sticker pack or send sticker pack to WhatsApp. \nError name: \(error)")
        }
    }
    
    
    // For Injection https://medium.com/@robnorback/the-secret-to-1-second-compile-times-in-xcode-9de4ec8345a1
    #if DEBUG
    @objc func injected() {
        func update() {
            for subview in self.view.subviews {
                subview.removeFromSuperview()
            }
            
            self.awakeFromNib()
            self.viewDidLoad()
            self.reloadInputViews()
            self.viewDidLoad()
        }
        
        if Thread.isMainThread {
            update()
        } else {
            DispatchQueue.main.sync {
                update()
            }
        }
    }
    #endif
}

extension String {
    var nsString: NSString {
        get { return self as NSString }
    }
    func isEmpty() -> Bool { return self == "" }
    static func isEmpty(_ str: String?) -> Bool { return str == "" }
}
extension NSString {
    var string: String {
        get { return self as String }
    }
}

extension UIImage {
    // From https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift/47402811#47402811
    func rotate(radians: CGFloat) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: radians)).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: radians)
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
extension UISearchBar {
    func setPlaceholderWhiteColor() {
        guard let textField = subviews.first?.subviews.last as? UITextField else { return }
        guard textField.subviews.count > 2 else { return }
        guard let placeholderLabel = textField.subviews[2] as? UILabel else { return }
        guard let searchImage = textField.subviews[1] as? UIImageView else { return }
        placeholderLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        textField.textColor = .white
        searchImage.image = Resources.Helper.whiteSearchIcon
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
