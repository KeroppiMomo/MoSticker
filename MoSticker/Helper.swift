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
    return (name ?? R.Common.noOwnerNameMessage) + (id == Auth.auth().currentUser?.uid ? R.Common.ownedMessage : "")
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
    func showErrorMessage(title: String?, message: String?, _ completion: @escaping () -> () = {}) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: R.Common.ok, style: .default, handler: { _ in
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
            self.showErrorMessage(title: "Error: Sticker Number Outside Allowable Range", message: "Failed to create sticker pack. A sticker pack must have at least 3 stickers and at most 30 stickers, but it currently has \(count) sticker\(count != 1 ? "s" : "").")
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

//extension UIImage {
//    func webPData(maxBytes: Int) -> Data? {
////        let tmpPath = NSTemporaryDirectory() + "tmpWebPConvertion.png"
////        try! self.pngData()!.write(to: URL(fileURLWithPath: tmpPath))
////        let refreshedImg = UIImage(contentsOfFile: tmpPath)!
//        if let cgImg = self.cgImage {
//            func createWebPData(lossless: Bool, quality: CGFloat, speed: Int32) -> Data? {
//                print("Creating ---- lossless: \(lossless), quality: \(quality), speed: \(speed)")
//                if let unmanagedData = YYCGImageCreateEncodedWebPData(cgImg, lossless, quality, speed, YYImagePreset.default) {
//
//                    let data = unmanagedData.takeUnretainedValue() as Data
//
//                    print("Size: \(data.count)")
//
//                    return data
//                } else { return nil }
//            }
//
//            let lossless: Bool
//            let minData: Data
//            if let test = createWebPData(lossless: false, quality: 0, speed: 6),
//                test.count <= maxBytes {
//                // lossless is possible
//                lossless = false
//                minData = test
////            } else if let test = createWebPData(lossless: false, quality: 0.01, speed: 6),
////                test.count <= maxBytes {
////                // lossy is possible
////                lossless = false
////                minData = test
//            } else {
//                // compression failed
//                return nil
//            }
//
//
//            var data: Data?
//            var size = Int.max
//            var quality: CGFloat = 1.0
//            repeat {
//                print("Quality: \(quality)")
//                data = createWebPData(lossless: lossless, quality: quality, speed: 6)
//                size = data == nil ? Int.max : data!.count
//                quality -= 0.1
//            } while quality > 0.0 && size > maxBytes
//
//            return data ?? minData
//        } else {
//            return nil
//        }
//
////        if let unmanagedData = WebPHelper.imageCreateEncodedWebPData(refreshedImg.cgImage!, targetSize: Int32(maxBytes), lossless: false) {
////            return unmanagedData.takeUnretainedValue() as Data
////        } else { return nil }
////        if let data = WebPManager.shared.encode(pngData: refreshedImg.pngData()!) {
////            return data
////        } else { return nil }
//    }
//
////    func webPData(maxBytes: Int) -> Data? {
////        if let unmanagedData = YYCGImageCreateEncodedWebPData(self.cgImage!, true, 0.5, 6, YYImagePreset.default) {
////            return unmanagedData.takeUnretainedValue() as Data
////        } else {
////            return nil
////        }
////    }
//
//    func pngData(maxBytes: Int) -> Data? {
//
////        guard let encoder = YYImageEncoder(type: .PNG) else { return nil }
////        encoder.quality
//
//
//        return nil
//
//    }
//}

//extension UIImage {
//    func pngData(maxBytes: Int) -> Data? {
//        if let png = self.pngData(), png.count < maxBytes {
//            return png
//        }
//
//        var quality: CGFloat = 1.0
//        var dataResult: Data?
//        while quality > 0.0 {
//            guard let jpg = self.jpegData(compressionQuality: quality),
//                let png = UIImage(data: jpg)?.pngData() else { continue }
//
//            if png.count < maxBytes {
//                dataResult = png
//                break
//            } else {
//                quality *= 0.9
//            }
//        }
//
//        return dataResult
//
//    }
//
//    func convertToWebP(quality: CGFloat, alpha: CGFloat) throws -> Data {
//        if alpha < 1 {
//            // ?
//        }
//
//        let webPImageRef = self.cgImage!
//        let webPImageWidth = webPImageRef.width
//        let webPImageHeight = webPImageRef.height
//
//        let webPDataProvider = webPImageRef.dataProvider!
//        let webPImageData = CGDataProviderCopyData(webPDataProvider)!
//
//        WebPManager().encode(pngData: <#T##Data#>)
//    }
//}

//func createARGBBitmapContext(in image: CGImage, size: CGSize) -> CGContext? {
//    let pixelWidth = Int(size.width)
//    let pixelHeight = Int(size.height)
//    let bitmapBytesPerRow = pixelWidth * 4
//    let bitmapByteCount = bitmapBytesPerRow * pixelHeight
//
//    let colorSpace = CGColorSpaceCreateDeviceRGB()
//
//    guard let bitmapData = malloc(bitmapByteCount) else { return nil }
//    guard let context = CGContext(data: bitmapData, width: pixelWidth, height: pixelHeight, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else {
//        free(bitmapData)
//        return nil
//    }
//
//    return context
//}
//func requestImagePixelData(in image: UIImage) -> UInt8? {
//    guard let cgImage = image.cgImage else { return nil }
//    let size = image.size
//
//    guard let cgCtx = createARGBBitmapContext(in: cgImage, size: size) else { return nil }
//
//    let rect = CGRect(origin: .zero, size: size)
//    cgCtx.draw(cgImage, in: rect)
//
//    let data = cgCtx.data!
////    let intData = data as! UnsafeMutableRawPointer<UInt32>
//
//
////    return data
//}
