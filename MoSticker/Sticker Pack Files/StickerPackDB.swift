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
import FirebaseFirestore

// MARK: - Error
enum PackDBError: Error {
    case noAuthError
    case dbFormatError
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
    static func getUserRef() -> DatabaseReference? {
        guard let uid = getUID() else { return nil }
        let ref = Database.database().reference(withPath: "users/\(uid)")
        return ref
    }
    static func getPackID() -> String {
        let packRef = Database.database().reference(withPath: "sticker_packs").childByAutoId()
        return packRef.key!
    }
    
    // MARK: - User Name
    static func getUserName(uid: String, _ completion: @escaping (String?) -> Void) {
        let userDoc = Firestore.firestore().collection("users").document(uid)
        userDoc.getDocument { (docSnap, error) in
            guard error == nil,
                let docSnap = docSnap,
                let name = docSnap.get("name") as? String else {
                
                completion(nil)
                return
            }
            completion(name)
        }
    }
    static func updateUserName(_ name: String, _ completion: @escaping (Error?) -> Void) {
        guard let uid = getUID() else {
            completion(PackDBError.noAuthError)
            return
        }
        
        let userDoc = Firestore.firestore().collection("users").document(uid)
        userDoc.updateData([ "name": name ], completion: completion)
    }
    
    // MARK: - Retrieve Packs
    
    static func getPack(_ packID: String, completion: @escaping (Error?, StickerPackDB?) -> Void) {
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
    static func parseSnapshot(_ snapshot: DataSnapshot, _ completion: @escaping (StickerPackDB?) -> Void) {
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
        
        guard var dataDict = snapshot.value as? [String: Any],
            let lastEditTimestamp = dataDict["last_edit"] as? Int,
            let name = dataDict["name"] as? String,
            let owner = dataDict["owner"] as? String,
            let trayBase64 = dataDict["tray"] as? String,
            let trayData = Data(base64Encoded: trayBase64),
            let pngData = base64Dict2Array(dataDict["sticker_png"] as? [String: String]),
            let webpData = base64Dict2Array(dataDict["sticker_webp"] as? [String: String]) else {
            completion(nil)
            return
        }
        
        let lastEdit = Date(timeIntervalSince1970: Double(lastEditTimestamp) / 1000)
        
        let pack = StickerPackDB()
        pack.lastEdit = lastEdit
        pack.name = name
        pack.owner = owner
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
        
        if dataDict["downloads"] == nil { dataDict["downloads"] = 0 }
        if let downloads = dataDict["downloads"] as? Int {
            pack.downloads = downloads
        } else {
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
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(pack)
        }
    }
    
    // MARK: - Write to DB
    func upload(completion: @escaping (Error?) -> Void) {
        var webpDict = [String: String]()
        var pngDict = [String: String]()
        for i in 0..<self.stickerWebP.count {
            let str = String(format: "%02d", i)
            webpDict[str] = self.stickerWebP[i].base64EncodedString()
            pngDict[str] = self.stickerPNGData[i].base64EncodedString()
        }

        let data: [String: Any] = [
            "name":         self.name!,
            "last_edit":    Timestamp(date: self.lastEdit!),
            "tray":         self.trayData!.base64EncodedString(),
            "pngs":         pngDict,
            "webps":        webpDict,
            "owner":        self.owner!
        ]
        
        let dispatchGroup = DispatchGroup()
        
        func writeCompletion(error: Error?) {
            if let error = error {
                completion(error)
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        let packDocRef = Firestore.firestore().document("packs/\(self.packID)")
        packDocRef.setData(data, completion: completion)
        
        dispatchGroup.enter()
        let downloadsDocRef = packDocRef.collection("counters").document("downloads")
        downloadsDocRef.setData([ "value": self.downloads ], completion: completion)
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    func delete(completion: @escaping (Error?) -> Void) {
        if let owner = self.owner, owner == Auth.auth().currentUser?.uid {
            let packDocRef = Firestore.firestore().collection("packs").document(self.packID)
            packDocRef.delete(completion: completion)
        }
    }
    
    // MARK: - Querying
    static func parseQuerySnap(_ querySnap: QuerySnapshot, sortBy order: @escaping (StickerPackDB, StickerPackDB) -> Bool, _ completion: @escaping (Error?, [StickerPackDB]?) -> Void) {
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
        
        var packs = [StickerPackDB]()
        let allDisGroup = DispatchGroup()
        
        for doc in querySnap.documents {
            let pack = StickerPackDB()
            guard let ownerUID = doc.get("owner") as? String,
                let name = doc.get("name") as? String,
                let lastEdit = doc.get("last_edit") as? Timestamp,
                let trayBase64 = doc.get("tray") as? String,
                let tray = Data(base64Encoded: trayBase64),
                let pngs = base64Dict2Array(doc.get("pngs") as? [String: String]),
                let webps = base64Dict2Array(doc.get("webps") as? [String: String]) else {
                    
                    printWarning("Ignoring bad database results")
                    continue
            }
            
            allDisGroup.enter()
            
            pack.owner = ownerUID
            pack.name = name
            pack.lastEdit = lastEdit.dateValue()
            pack.trayData = tray
            pack.stickerPNGData = pngs
            pack.stickerWebP = webps
            pack.packID = doc.reference.documentID
            
            let packDisGroup = DispatchGroup()
            packDisGroup.enter()
            doc.reference.collection("counters").document("downloads").getDocument(completion: { (docSnap, error) in
                if let error = error {
                    completion(error, nil)
                    packDisGroup.leave()
                    return
                }
                guard let docSnap = docSnap, let value = docSnap.get("value") as? Int else {
                    printWarning("Ignoring bad database results")
                    packDisGroup.leave()
                    return
                }
                pack.downloads = value
                packDisGroup.leave()
            })
            packDisGroup.enter()
            StickerPackDB.getUserName(uid: ownerUID, { (userName) in
                if let userName = userName {
                    pack.ownerName = userName
                }
                packDisGroup.leave()
            })
            
            packDisGroup.notify(queue: .main) {
                allDisGroup.leave()
                packs.append(pack)
            }
        }
        
        allDisGroup.notify(queue: .main) {
            packs.sort(by: order)
            completion(nil, packs)
        }
    }
    static func getUserAllPacks(_ completion: @escaping (Error?, [StickerPackDB]?) -> Void) {
        guard let uid = getUID() else {
            completion(PackDBError.noAuthError, nil)
            return
        }
        let collection = Firestore.firestore().collection("packs")
        let query = collection.whereField("owner", isEqualTo: uid)
        query.addSnapshotListener { (querySnap, error) in
            if let error = error {
                completion(error, nil)
                return
            }
            guard let querySnap = querySnap else { return }
            
            parseQuerySnap(querySnap, sortBy: { $0.lastEdit! > $1.lastEdit! }, completion)
        }
    }
    private static func parse(query querySnap: DataSnapshot, sortBy order: @escaping (StickerPackDB, StickerPackDB) -> Bool, _ completion: @escaping ([StickerPackDB]) -> Void) {
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
            results.sort(by: order)
            completion(results)
        })
    }
    static func query(with searchText: String, _ completion: @escaping ([StickerPackDB]) -> Void) {
        let searchText = searchText.lowercased()
        
        let ref = Database.database().reference(withPath: "sticker_packs")
        let query = ref.queryOrdered(byChild: "name_lowercased").queryStarting(atValue: searchText).queryEnding(atValue: searchText + "\u{f8ff}").queryLimited(toFirst: UInt(Rc.queryItemNo))
        query.removeAllObservers()
        query.observeSingleEvent(of: .value, with: { querySnap in
            parse(query: querySnap, sortBy: { $0.lastEdit! > $1.lastEdit! }, completion)
        })
    }
    static func getMostDownloaded(numberOfItems: Int, _ completion: @escaping ([StickerPackDB]) -> Void) {
        let ref = Database.database().reference(withPath: "sticker_packs")
        let query = ref.queryOrdered(byChild: "downloads").queryLimited(toLast: UInt(numberOfItems))
        query.observeSingleEvent(of: .value) { (querySnap) in
            parse(query: querySnap, sortBy: { $0.downloads > $1.downloads }, completion)
        }
    }
    static func getMostRecent(numberOfItems: Int, _ completion: @escaping ([StickerPackDB]) -> Void) {
        let ref = Database.database().reference(withPath: "sticker_packs")
        let query = ref.queryOrdered(byChild: "last_edit").queryLimited(toFirst: UInt(numberOfItems))
        query.observeSingleEvent(of: .value) { (querySnap) in
            parse(query: querySnap, sortBy: { $0.lastEdit! > $1.lastEdit! }, completion)
        }
    }
    
    // MARK: - Stats
    func sendToWhatsAppWithStats(completion: @escaping (Bool) -> Void) throws {
        try self.sendToWhatsApp(id: self.packID, publisher: (self.ownerName ?? "") + Rc.publisherSuffix, completion: completion)
        
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
