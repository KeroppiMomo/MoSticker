////
////  DBPaths.swift
////  MoSticker
////
////  Created by Moses Mok on 3/2/2019.
////  Copyright © 2019 Moses Mok. All rights reserved.
////
//
//import Foundation
//import FirebaseDatabase
//
//protocol DBPathStaticDelegate {
//    static var path: String { get }
//    static var ref: DatabaseReference { get }
//}
//protocol DBPathInstanceDelegate {
//    var path: String { get }
//    var ref: DatabaseReference { get }
//}
//extension DBPathStaticDelegate {
//    static var ref: DatabaseReference { return Database.database().reference(withPath: path) }
//}
//extension DBPathInstanceDelegate {
//    var ref: DatabaseReference { return Database.database().reference(withPath: path) }
//}
//
//class DBPaths: DBPathStaticDelegate {
//    static var path: String { return "" }
//
//    class users: DBPathStaticDelegate {
//        static var path: String { return "users" }
//
//        static func uid(_ uid: String) -> DBPathInstanceDelegate {
//            let user = _User()
//            user.uid = uid
//            return user
//        }
//
//        private class _User: DBPathInstanceDelegate {
//            var uid = ""
//            var path: String { return "users/" + uid }
//        }
//    }
//}
