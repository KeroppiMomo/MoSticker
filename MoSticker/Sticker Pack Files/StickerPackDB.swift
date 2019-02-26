//
//  StickerPackDB.swift
//  MoSticker
//
//  Created by Moses Mok on 12/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

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
    static func getPackID() -> String {
        let packRef = Firestore.firestore().collection("packs").document()
        return packRef.documentID
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
    static func observeCurrentUserName(_ completion: @escaping (String?) -> Void) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let userDoc = Firestore.firestore().collection("users").document(user.uid)
                userDoc.getDocument { (docSnap, error) in
                    guard error == nil,
                        let docSnap = docSnap,
                        let name = docSnap.get("name") as? String else {
                            
                        completion(nil)
                        return
                    }
                    completion(name)
                }
            } else {
                completion(nil)
            }
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
    
    // MARK: - Write to DB
    func upload(completion: @escaping (Error?) -> Void) {
        var webpDict = [String: String]()
        var pngDict = [String: String]()
        for i in 0..<self.stickerWebP.count {
            let str = String(format: "%02d", i)
            webpDict[str] = self.stickerWebP[i].base64EncodedString()
            pngDict[str] = self.stickerPNGData[i].base64EncodedString()
        }

        var data: [String: Any] = [
            "name":         self.name!,
            "last_edit":    Timestamp(date: self.lastEdit!),
            "tray":         self.trayData!.base64EncodedString(),
            "pngs":         pngDict,
            "webps":        webpDict,
            "owner":        self.owner!
        ]
        
        let packDocRef = Firestore.firestore().document("packs/\(self.packID)")
        packDocRef.getDocument { (snapshot, error) in
            if snapshot?.exists ?? false {
                packDocRef.updateData(data, completion: completion)
            } else {
                data["downloads"] = 0
                packDocRef.setData(data, completion: completion)
            }
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
            let downloads = doc.get("downloads") as? Int ?? 0
            
            allDisGroup.enter()
            
            pack.owner = ownerUID
            pack.name = name
            pack.lastEdit = lastEdit.dateValue()
            pack.trayData = tray
            pack.stickerPNGData = pngs
            pack.stickerWebP = webps
            pack.packID = doc.reference.documentID
            pack.downloads = downloads

            StickerPackDB.getUserName(uid: ownerUID, { (userName) in
                if let userName = userName {
                    pack.ownerName = userName
                }
                packs.append(pack)
                allDisGroup.leave()
            })
        }
        
        allDisGroup.notify(queue: .main) {
            packs.sort(by: order)
            completion(nil, packs)
        }
    }
    static func observeUserPacks(_ completion: @escaping (Error?, [StickerPackDB]?) -> Void) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                let uid = user.uid
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
            } else {
                completion(nil, [])
            }
        }
    }
    static func searchPacks(with searchText: String, _ completion: @escaping (Error?, [StickerPackDB]?) -> Void) {
        let searchText = searchText.lowercased()
        let searchTerms = searchText.split(separator: " ")
        var query: Query = Firestore.firestore().collection("packs")
        for term in searchTerms {
            query = query.whereField("search_terms", arrayContains: term)
        }
        query = query.order(by: "downloads", descending: true).limit(to: Rc.queryItemNo)
        query.getDocuments { (querySnap, error) in
            if let error = error {
                completion(error, nil)
                return
            }
            guard let querySnap = querySnap else { return }
            parseQuerySnap(querySnap, sortBy: { $0.downloads > $1.downloads }, completion)
        }
    }
    static func getMostDownloaded(numberOfItems: Int, _ completion: @escaping (Error?, [StickerPackDB]?) -> Void) {
        let query = Firestore.firestore().collection("packs").order(by: "downloads", descending: true).limit(to: numberOfItems)
        query.getDocuments { (querySnap, error) in
            if let error = error {
                completion(error, nil)
                return
            }
            guard let querySnap = querySnap else { return }
            parseQuerySnap(querySnap, sortBy: { $0.downloads > $1.downloads }, completion)
        }
    }
    static func getMostRecent(numberOfItems: Int, _ completion: @escaping (Error?, [StickerPackDB]?) -> Void) {
        let query = Firestore.firestore().collection("packs").order(by: "last_edit", descending: true).limit(to: numberOfItems)
        query.getDocuments { (querySnap, error) in
            if let error = error {
                completion(error, nil)
                return
            }
            guard let querySnap = querySnap else { return }
            parseQuerySnap(querySnap, sortBy: { $0.lastEdit! > $1.lastEdit! }, completion)
        }
    }
    
    // MARK: - Stats
    func sendToWhatsAppWithStats(completion: @escaping (Bool) -> Void) throws {
        try self.sendToWhatsApp(id: self.packID, publisher: (self.ownerName ?? "") + Rc.publisherSuffix, completion: completion)
        
        Functions.functions().httpsCallable("count_downloads").call(["packID": self.packID]) { (_, error) in
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
