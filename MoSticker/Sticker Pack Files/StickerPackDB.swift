//
//  StickerPackDB.swift
//  MoSticker
//
//  Created by Moses Mok on 12/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

// MARK: - Error
enum PackDBError: Error {
    case noAuthError
    case dbFormatError
}
// MARK: - Changes
enum PackChanges {
    case added
    case changed
    case removed
    case all
}
// MARK: - StickerPackDB
class StickerPackDB: StickerPackBase {
    
    // MARK: - Convenience Functions
    static func getUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    static func getUserPackRef() -> DatabaseReference? {
        guard let uid = getUID() else { return nil }
        let ref = Database.database().reference(withPath: "users/\(uid)/sticker_packs")
        return ref
    }
    static func getPackID() -> String {
        let packRef = Database.database().reference(withPath: "sticker_packs").childByAutoId()
        return packRef.key!
    }
    
    // MARK: - User Name
    static func getUserName(uid: String, _ completion: @escaping (String?) -> ()) {
        let nameRef = Database.database().reference(withPath: "users/\(uid)/name")
        nameRef.observeSingleEvent(of: .value) { (nameSnap) in
            completion(nameSnap.value as? String)
        }
    }
    static func updateUserName(_ name: String, _ completion: @escaping (Error?) -> ()) {
        guard let uid = getUID() else {
            completion(PackDBError.noAuthError)
            return
        }
        
        let ref = Database.database().reference(withPath: "users/\(uid)/name")
        ref.setValue(name) { (error, _) in
            completion(error)
        }
    }
    
    // MARK: - Retrieve Packs
    static func getAllPacks(_ completion: @escaping (Error?, [StickerPackDB]?) -> ()) {
        guard let userPackRef = getUserPackRef() else {
            completion(PackDBError.noAuthError, nil)
            return
        }
        userPackRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                completion(nil, [])
                return
            }
            guard let snapDict = snapshot.value as? [String: String] else {
                completion(PackDBError.dbFormatError, nil)
                return
            }
            
            var errorOccurred = false
            let dispatchGroup = DispatchGroup()
            var packs = [StickerPackDB]()
            for (_, packID) in snapDict {
                dispatchGroup.enter()
                getPack(packID, completion: { (error, pack) in
                    if let error = error {
                        errorOccurred = true
                        completion(error, nil)
                    } else if let pack = pack {
                        packs.append(pack)
                    }
                    dispatchGroup.leave()
                })
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                if !errorOccurred {
                    packs.sort(by: { $0.lastEdit! > $1.lastEdit! })
                    completion(nil, packs)
                }
            })
        })
    }
    static func getPack(_ packID: String, completion: @escaping (Error?, StickerPackDB?) -> ()) {
        let packRef = Database.database().reference(withPath: "sticker_packs").child(packID)
        packRef.observeSingleEvent(of: .value) { (snapshot) in

            parseSnapshot(snapshot, { (pack) in
                guard let pack = pack else {
                    completion(PackDBError.dbFormatError, nil)
                    return
                }

                completion(nil, pack)
            })
        }
    }
    static func parseSnapshot(_ snapshot: DataSnapshot, _ completion: @escaping (StickerPackDB?) -> ()) {
        func base64Dict2Array(_ dict: [String: String]?) -> [Data]? {
            if dict == nil {
                return nil
            }
            let base64s = dict!.sorted { $0.key < $1.key }.map { $0.value }
            
            var result = [Data]()
            for base64 in base64s {
                if let data = Data(base64Encoded: base64) {
                    result.append(data)
                }
            }
            
            return result
        }
        
        guard let dataDict = snapshot.value as? [String: Any],
            let id = dataDict["id"] as? String,
            let lastEditTimestamp = dataDict["last_edit"] as? Int,
            let name = dataDict["name"] as? String,
            let owner = dataDict["owner"] as? String,
            let publisher = dataDict["publisher"] as? String,
            let trayBase64 = dataDict["tray"] as? String,
            let trayData = Data(base64Encoded: trayBase64),
            let pngData = base64Dict2Array(dataDict["sticker_png"] as? [String: String]),
            let webpData = base64Dict2Array(dataDict["sticker_webp"] as? [String: String]) else {
            completion(nil)
            return
        }
        
        let lastEdit = Date(timeIntervalSince1970: Double(lastEditTimestamp) / 1000)
        
        let pack = StickerPackDB()
        pack.id = id
        pack.lastEdit = lastEdit
        pack.name = name
        pack.owner = owner
        pack.publisher = publisher
        pack.trayData = trayData
        pack.stickerPNGData = pngData
        pack.stickerWebP = webpData
        pack.packID = snapshot.key
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        StickerPackDB.getUserName(uid: pack.owner!) { (ownerName) in
            pack.ownerName = ownerName
            dispatchGroup.leave()
        }
        
        let downloadCountsRef = Database.database().reference(withPath: "pack_download_counts/" + pack.packID)
        dispatchGroup.enter()
        downloadCountsRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let downloads = snapshot.value as? Int else {
                dispatchGroup.leave()
                return
            }
            pack.downloads = downloads
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(pack)
        }
    }
    static func observe(_ changes: @escaping (Error?, PackChanges, StickerPackDB?) -> ()) {
        var userPackRef: DatabaseReference?
        var packObserveRefs = [DatabaseReference]()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            printInfo("Auth state changed. Attaching observers.")

            userPackRef?.removeAllObservers()
            packObserveRefs.forEach { $0.removeAllObservers() }
            packObserveRefs.removeAll()
            
            changes(nil, .all, nil)
            userPackRef = StickerPackDB.getUserPackRef()
            StickerPackDB.getUserPackRef()?.observe(.childAdded, with: { (snapshot) in
                guard let packID = snapshot.value as? String else {
                    changes(PackDBError.dbFormatError, .added, nil)
                    return
                }
                getPack(packID, completion: { (error, pack) in
                    changes(error, .added, pack)
                })
                let packRef = Database.database().reference(withPath: "sticker_packs/" + packID)
                packRef.observe(.childChanged) { (snapshot) in
                    getPack(packID, completion: { (error, pack) in
                        changes(error, .changed, pack)
                    })
                }
                packObserveRefs.append(packRef)
            })
            StickerPackDB.getUserPackRef()?.observe(.childChanged, with: { (snapshot) in
                guard let packID = snapshot.value as? String else {
                    changes(PackDBError.dbFormatError, .added, nil)
                    return
                }
                getPack(packID, completion: { (error, pack) in
                    changes(error, .changed, pack)
                })
            })
            StickerPackDB.getUserPackRef()?.observe(.childRemoved, with: { (snapshot) in
                guard let packID = snapshot.value as? String else {
                    changes(PackDBError.dbFormatError, .removed, nil)
                    return
                }
                let removedPack = StickerPackDB()
                removedPack.packID = packID
                changes(nil, .removed, removedPack)
            })
        }
    }
    
    // MARK: - Write to DB
    func upload(completion: @escaping (Error?) -> ()) {
        guard let userLinkRef = StickerPackDB.getUserPackRef() else {
            completion(PackDBError.noAuthError)
            return
        }
        if self.owner == nil { self.owner = Auth.auth().currentUser!.uid }
        
        let db = Database.database()
        let packRef = db.reference(withPath: "sticker_packs").child(packID)
        
        if let error = self.validate(WhatsApp: false) {
            completion(error)
            return
        }
        
        var webpDict = [String: String]()
        var pngDict = [String: String]()
        for i in 0..<self.stickerWebP.count {
            let str = String(format: "%02d", i)
            webpDict[str] = self.stickerWebP[i].base64EncodedString()
            pngDict[str] = self.stickerPNGData[i].base64EncodedString()
        }
        let dataDict: [String: Any] = [
            "name": self.name!,
            "name_lowercased": self.name!.lowercased(),
            "id": self.id!,
            "publisher": self.publisher!,
            "tray": self.trayData!.base64EncodedString(),
            "last_edit": Int64(self.lastEdit!.timeIntervalSince1970 * 1000),
            "sticker_webp": webpDict,
            "sticker_png": pngDict,
            "owner": self.owner!
        ]
        
        packRef.updateChildValues(dataDict) { (error, _) in
            if let error = error {
                completion(error)
                return
            }
            userLinkRef.child(self.packID).setValue(self.packID, withCompletionBlock: { (error, _) in
                completion(error)
            })
        }
    }
    func delete(completion: @escaping (Error?) -> ()) {
        if let owner = self.owner, owner == Auth.auth().currentUser?.uid {
            let packRef = Database.database().reference(withPath: "sticker_packs").child(self.packID)
            packRef.removeValue { (error, _) in
                if let error = error {
                    completion(error)
                    return
                }
                StickerPackDB.getUserPackRef()!.child(self.packID).removeValue(completionBlock: { (error, _) in
                    completion(error)
                })
            }
        }
    }
    
    // MARK: - Querying
    static func query(with searchText: String, _ completion: @escaping ([StickerPackDB]) -> ()) {
        let searchText = searchText.lowercased()
        
        let ref = Database.database().reference(withPath: "sticker_packs")
        let query = ref.queryOrdered(byChild: "name_lowercased").queryStarting(atValue: searchText).queryEnding(atValue: searchText + "\u{f8ff}").queryLimited(toFirst: 100)
        query.removeAllObservers()
        query.observe(.value, with: { querySnap in
            var results = [StickerPackDB]()
            
            let group = DispatchGroup()
            for case let packSnap as DataSnapshot in querySnap.children {
                group.enter()
                parseSnapshot(packSnap, { (pack) in
                    guard let pack = pack else {
                        printWarning("Ignoring bad pack.")
                        return
                    }
                    results.append(pack)
                    
                    group.leave()
                })
            }
            
            group.notify(queue: .main, execute: {
                results.sort { $0.lastEdit! > $1.lastEdit! }
                completion(results)
            })
        })
    }
    
    // MARK: - Stats
    func sendToWhatsAppWithStats(publisherSuffix: String, completion: @escaping (Bool) -> Void) throws {
        try self.sendToWhatsApp(publisherSuffix: publisherSuffix, completion: completion)
        
        let downloadsRef = Database.database().reference(withPath: "pack_download_counts/" + packID)
        downloadsRef.runTransactionBlock({ curData -> TransactionResult in
            let downloads = (curData.value as? Int) ?? 0
            curData.value = downloads + 1
            
            return TransactionResult.success(withValue: curData)
        }) { (error, _, _) in
            if let error = error {
                printError(error)
            }
        }
    }
    
    // MARK: - Fields
    var owner: String?
    var ownerName: String?
    var packID = getPackID()
    var downloads = 0
    
    override var description: String {
        return "<\(type(of: self))>: \(packID) '\(name ?? "[nil name]")'"
    }
}
