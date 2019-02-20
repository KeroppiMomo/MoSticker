//
//  AppDelegate.swift
//  MoSticker
//
//  Created by Moses Mok on 29/11/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        Bundle(path: Resources.AD.injectionPath)?.load()
        #endif
        
        FirebaseApp.configure()
        StickerPackDB.getUserRef()?.keepSynced(true)
        
        do {
            printInfo("Sticker Packs saving path: \(try StickerPackLocal.getPackPath())")
        } catch {
            printError("Failed to get sticker packs saving path")
        }
        
        if let tabController = window?.rootViewController as? UITabBarController {
            let tabBar = tabController.tabBar
            tabBar.unselectedItemTintColor = UIColor.appLightGreen
        }
        
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        
        // FirebaseUI
        guard FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: options[.sourceApplication] as? String) ?? false else { return false }
        
        return true
    }
}

