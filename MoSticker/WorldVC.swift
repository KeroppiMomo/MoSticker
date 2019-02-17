//
//  WorldVC.swift
//  MoSticker
//
//  Created by Moses Mok on 17/2/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

fileprivate typealias R = Resources.WoVC
typealias QueryCategory = (name: String, getPacks: (@escaping ([StickerPackDB]) -> ()) -> (), result: [StickerPackDB]?)

class WorldVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var CATEGORIES: [QueryCategory] = [
        (name: "Most Downloaded", getPacks: StickerPackDB.getMostDownloaded, result: nil)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<CATEGORIES.count {
            CATEGORIES[i].getPacks { result in
                self.CATEGORIES[i].result = result
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return CATEGORIES.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = CATEGORIES[section]
        if let packs = category.result {
            return packs.count + 1 // 1 is the header cell
        } else {
            return 2 // Header cell + Loading cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 70 }
        else if CATEGORIES[indexPath.section].result == nil { return 44 }
        else { return 138 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            // Header cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.headerCellID, for: indexPath) as? BoldHeaderTableViewCell else { return UITableViewCell() }
            cell.setup(text: "Header", buttonText: "Show More")
            return cell
        } else if let packs = CATEGORIES[indexPath.section].result {
            // Pack cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.packCellID, for: indexPath) as? StickerPackTableViewCell else { return UITableViewCell() }
            return cell
        } else {
            // Loading cell
            return tableView.dequeueReusableCell(withIdentifier: R.loadingCellID, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
}
