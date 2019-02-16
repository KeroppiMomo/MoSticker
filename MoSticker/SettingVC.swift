//
//  SettingVC.swift
//  MoSticker
//
//  Created by Moses Mok on 9/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit
import FirebaseUI

fileprivate typealias R = Resources.SetVC
class SettingVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FUIAuthDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    static var CELL_TITLES: [[(String, String)]] {
        get {
            return [
                [
                    (Auth.auth().currentUser == nil ? R.logInSignUp : R.logOut, R.disclosureCellID)
                ]
            ]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return SettingVC.CELL_TITLES.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingVC.CELL_TITLES[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = SettingVC.CELL_TITLES[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellInfo.1, for: indexPath)
        cell.textLabel?.text = cellInfo.0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            if Auth.auth().currentUser == nil {
                guard let authUI = FUIAuth.defaultAuthUI() else { return }
                authUI.delegate = self
                authUI.providers = [
                    FUIGoogleAuth(), FUIPhoneAuth(authUI: FUIAuth.defaultAuthUI()!)
                ]
                let authVC = authUI.authViewController()
                
                present(authVC, animated: true, completion: nil)
            } else {
                guard let authUI = FUIAuth.defaultAuthUI() else { return }
                
                do {
                    try authUI.signOut()
                    tableView.reloadData()
                } catch {
                    self.showErrorMessage(title: R.signOutErrorTitle, message: R.signOutErrorMessage)
                    printError(error)
                }
            }
        }
    }
}
