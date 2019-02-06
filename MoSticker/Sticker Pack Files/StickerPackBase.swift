//
//  StickerPackObj.swift
//  MoSticker
//
//  Created by Moses Mok on 12/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

// MARK: Errors
enum WhatsAppPackError: Error {
    case whatsAppUnavailable
    case fieldEmptyError(field: String)
    case fieldCharCountError(field: String, count: Int, max: Int)
    case stickerNoError(count: Int)
    case trayImagePNGError
}

// MARK: - StickerPackBase
class StickerPackBase: CustomStringConvertible {
    // MARK: - Date Formatter
    static var dateFormatter: DateFormatter {
        get {
            let df = DateFormatter()
            df.dateFormat = "yyyyMMddHHmmss"
            return df
        }
    }
    
    // MARK: - Convenience Functions
    static func checkIDLegal(id: String) -> Bool {
        var legalChar = CharacterSet.alphanumerics
        legalChar.insert(charactersIn: "_-. ")
        
        return id == id.components(separatedBy: legalChar.inverted).joined() && id.count < Limits.MaxCharLimit128
    }
    
    // MARK: - Pack Output
    func validate(WhatsApp required: Bool) -> Error? {
        // Check WhatsApp avaliability
        if required {
            guard Interoperability.canSend() else { return WhatsAppPackError.whatsAppUnavailable }
        }
        
        // Check whether name, id and tray image exist
        guard name != nil && name != "" else { return WhatsAppPackError.fieldEmptyError(field: "Name" )}
        guard trayData != nil else { return WhatsAppPackError.fieldEmptyError(field: "Pack Icon")}
        // Check name and id character limit
        guard name!.count < Limits.MaxCharLimit128 else { return WhatsAppPackError.fieldCharCountError(field: "Name", count: name!.count, max: Limits.MaxCharLimit128)}
        // Check sticker images number
        guard stickerWebP.count <= 30 && stickerWebP.count >= 3 else { return WhatsAppPackError.stickerNoError(count: stickerWebP.count) }
        
        return nil
    }
    func sendToWhatsApp(id: String, publisher: String, completion: @escaping (Bool) -> Void) throws {
        
        let pack = try StickerPack(identifier: id, name: name!, publisher: publisher, trayImagePNGData: trayData!, publisherWebsite: nil, privacyPolicyWebsite: nil, licenseAgreementWebsite: nil)
        
        for stickerData in stickerWebP {
            try pack.addSticker(imageData: stickerData, type: .webp, emojis: nil)
        }
        
        pack.sendToWhatsApp(completionHandler: completion)
    }
    func toJSON(id: String, publisher: String) throws -> [String: Any] {
        let pack = try StickerPack(identifier: id, name: name!, publisher: publisher, trayImagePNGData: trayData!, publisherWebsite: nil, privacyPolicyWebsite: nil, licenseAgreementWebsite: nil)
        
        for stickerData in stickerWebP {
            try pack.addSticker(imageData: stickerData, type: .webp, emojis: nil)
        }
        
        var json: [String: Any] = [:]
        json["identifier"] = pack.identifier
        json["name"] = pack.name
        json["publisher"] = pack.publisher
        json["tray_image"] = pack.trayImage.image!.pngData()?.base64EncodedString()
        
        var stickersArray: [[String: Any]] = []
        for sticker in pack.stickers {
            var stickerDict: [String: Any] = [:]
            
            if let imageData = sticker.imageData.webpData {
                stickerDict["image_data"] = imageData.base64EncodedString()
            } else {
                printWarning("Skipping bad sticker data")
                continue
            }
            
            stickerDict["emojis"] = sticker.emojis
            
            stickersArray.append(stickerDict)
        }
        json["stickers"] = stickersArray
        
        return json
    }
    
    // MARK: - Fields
    var trayData: Data?
    var stickerWebP = [Data]()
    var stickerPNGData = [Data]()
    var name: String?
    var lastEdit: Date?
    
    // MARK: - Pack Operation from UI
    func getTrayImages() -> UIImage? {
        guard let data = trayData else { return nil }
        return UIImage(data: data)
    }
    func getStickerImages() -> [UIImage?] {
        return stickerPNGData.map({ UIImage(data: $0) })
    }
    func appendSticker(webPData: Data, pngData: Data) {
        stickerWebP.append(webPData)
        stickerPNGData.append(pngData)
    }
    func removeSticker(at index: Int) {
        stickerWebP.remove(at: index)
        stickerPNGData.remove(at: index)
    }
    
    // MARK: - CustomStringConvertible
    var description: String {
        return "<\(type(of: self))>: '\(name ?? "[nil name]")'"
    }
}
