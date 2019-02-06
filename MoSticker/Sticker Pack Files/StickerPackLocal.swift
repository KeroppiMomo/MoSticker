//
//  StickerPackLocal.swift
//  MoSticker
//
//  Created by Moses Mok on 19/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import Foundation
import UIKit
import YYImage

enum PackIOError: Error {
    case pathNotFound
    case writeOperationError
    case deleteOperationError
    case createDirectoryError
    case fileFormatError
    case listDirectoryError
    case savingIDMissingError
    case jsonConvertionError
}
class StickerPackLocal: StickerPackBase {
    
    // MARK: - Convenience Functions
    static func getPackPath() throws -> String {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            throw PackIOError.pathNotFound
        }
        return documentPath.nsString.appendingPathComponent("StickerPacks")
    }
    static func generateID() throws -> String {
        var id: String
        repeat {
            id = UUID().uuidString
        }
        while try FileManager().fileExists(atPath: getPackPath().nsString.appendingPathComponent(id))
        
        return id
    }
    
    // MARK: - Retrieve Packs
    static func getAllPacks() throws -> [StickerPackLocal] {
        let path = try getPackPath()
        guard FileManager().fileExists(atPath: path) else { return [StickerPackLocal]() }
        let packIDs: [String]
        do {
            packIDs = try FileManager().contentsOfDirectory(atPath: path)
        } catch {
            throw PackIOError.listDirectoryError
        }
        
        return try packIDs.map { try getPack(savingID: $0) }.sorted(by: { $0.lastEdit! > $1.lastEdit! })
    }
    static func getPack(savingID: String) throws -> StickerPackLocal {
        let path = try getPackPath().nsString.appendingPathComponent(savingID)
        
        let resultPack = StickerPackLocal()
        
        let infoPath = path.nsString.appendingPathComponent("INFO.mopackinfo")
        guard FileManager().fileExists(atPath: infoPath) else {
            throw PackIOError.pathNotFound
        }
        
        let infoContent: String
        do {
            infoContent = try String(contentsOfFile: infoPath, encoding: .ascii)
        } catch {
            throw PackIOError.pathNotFound
        }
        
        // See comments in savePack(savingID:)
        guard let urlComponent = URLComponents(string: infoContent),
            urlComponent.path == "mostickerpack" else {
                throw PackIOError.fileFormatError
        }
        let query = (urlComponent.queryItems ?? []).reduce([String: String]()) { (dict, item) -> [String: String] in
            var dict = dict
            dict[item.name] = item.value ?? ""
            return dict
        }
        resultPack.name = query["name"]
        resultPack.lastEdit = StickerPackLocal.dateFormatter.date(from: query["lastedit"] ?? "")
        resultPack.savingID = savingID
        
        if let trayBase64 = query["tray"],
            let trayData = Data(base64Encoded: trayBase64) {
            resultPack.trayData = trayData
        }
        let noOfStickers = Int(query["noofstickers"] ?? "0") ?? 0
        for i in 0..<noOfStickers {
            let webpName = String(format: "s_webp_%02d.png", i)
            let pngName = String(format: "s_png_%02d.png", i)
            if let stickerWebPBase64 = query[webpName],
                let stickerData = Data(base64Encoded: stickerWebPBase64) {
                resultPack.stickerWebP.append(stickerData)
            }
            if let stickerPNGBase64 = query[pngName],
                let stickerData = Data(base64Encoded: stickerPNGBase64) {
                resultPack.stickerPNGData.append(stickerData)
            }
        }
        
        return resultPack
    }
    
    // MARK: - Pack IO
    func savePack() throws {
        if savingID == nil {
            throw PackIOError.savingIDMissingError
        }
        
        // To prevent problem stated in https://stackoverflow.com/questions/10685276/iphone-ios-saving-data-obtained-from-uiimagejpegrepresentation-fails-second-ti
        let path = NSTemporaryDirectory() + "StickerPackCreation/\(savingID!)"
        
        do {
            try FileManager().createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw PackIOError.createDirectoryError
        }
        
        do {
            // Just trying to turn the fields into a url-formatted-query-shaped thing
            var components = URLComponents()
            components.path = "mostickerpack"
            components.queryItems = [
                URLQueryItem(name: "name", value: name),
                URLQueryItem(name: "lastedit", value: lastEdit == nil ? nil : StickerPackLocal.dateFormatter.string(from: lastEdit!)),
                URLQueryItem(name: "noofstickers", value: String(stickerWebP.count)),
                URLQueryItem(name: "_version", value: getAppVersion())
            ]
            if let trayBase64 = trayData?.base64EncodedString() {
                components.queryItems!.append(URLQueryItem(name: "tray", value: trayBase64))
            }
            // WebP
            for i in 0..<stickerWebP.count {
                let name = String(format: "s_webp_%02d.png", i)
                let stickerBase64 = stickerWebP[i].base64EncodedString()
                components.queryItems!.append(URLQueryItem(name: name, value: stickerBase64))
            }
            // PNG
            for i in 0..<stickerPNGData.count {
                let name = String(format: "s_png_%02d.png", i)
                let stickerBase64 = stickerPNGData[i].base64EncodedString()
                components.queryItems!.append(URLQueryItem(name: name, value: stickerBase64))
            }

            if let infoContent = components.url?.absoluteString {
                let infoPath = path.nsString.appendingPathComponent("INFO.mopackinfo")
                try infoContent.write(toFile: infoPath, atomically: true, encoding: .ascii)
            } else {
                throw PackIOError.writeOperationError
            }
            
            let savingPath = try StickerPackLocal.getPackPath().nsString.appendingPathComponent(savingID!)
            if FileManager().fileExists(atPath: savingPath) {
                do {
                    try FileManager().removeItem(atPath: savingPath)
                } catch {
                    throw PackIOError.deleteOperationError
                }
            }
            do {
                try FileManager().createDirectory(atPath: try! StickerPackLocal.getPackPath(), withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw PackIOError.createDirectoryError
            }

            
            try FileManager().moveItem(atPath: path, toPath: savingPath)
            
        } catch {
            throw PackIOError.writeOperationError
        }
    }
    func deletePack() throws {
        if savingID == nil { return }
        
        let savingPath = try StickerPackLocal.getPackPath().nsString.appendingPathComponent(savingID!)
        if FileManager().fileExists(atPath: savingPath) {
            do {
                try FileManager().removeItem(atPath: savingPath)
            } catch {
                throw PackIOError.deleteOperationError
            }
        } else {
            throw PackIOError.pathNotFound
        }
    }
    
    // MARK: - Send to WhatsApp
    func sendToWhatsApp(completion: @escaping (Bool) -> Void) throws {
        try super.sendToWhatsApp(id: self.savingID!, publisher: R.Common.publisherLocal, completion: completion)
    }
    
    // MARK: - Type Convertion
    func toPackDB() -> StickerPackDB {
        let result = StickerPackDB()
        result.lastEdit = self.lastEdit
        result.name = self.name
        result.stickerPNGData = self.stickerPNGData
        result.stickerWebP = self.stickerWebP
        result.trayData = self.trayData
        result.owner = StickerPackDB.getUID()
        return result
    }
    
    // MARK: - Fields
    var savingID: String?
    
    // MARK: - CustomStringConvertible
    override var description: String {
        return "<\(type(of: self))>: \(savingID ?? "[nil savingID]") '\(name ?? "[nil name]")'"
    }
}
