//
//  WorldVC.swift
//  MoSticker
//
//  Created by Moses Mok on 17/2/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

fileprivate typealias R = Resources.WoVC
class WorldVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<R.categories.count {
            R.categories[i].getPacks(R.maxPacksShown) { (error, result) in
                if let error = error {
                    self.showErrorMessage(title: R.queryErrorTitle, message: R.queryErrorMessage)
                    printError(error)
                    return
                }
                guard let result = result else { return }
                R.categories[i].result = result
                self.tableView.reloadSections([i], with: .automatic)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return R.categories.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = R.categories[section]
        if let packs = category.result {
            return packs.count.clamped(to: 0...R.maxPacksShown) + 2 // 2 is the header cell + "show more" cell
        } else {
            return 2 // Header cell + Loading cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 70 }
        else if indexPath.row == R.maxPacksShown + 1 { return 44 }
        else if R.categories[indexPath.section].result == nil { return 44 }
        else { return 180 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = R.categories[indexPath.section]
        if indexPath.row == 0 {
            // Header cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.headerCellID, for: indexPath) as? BoldHeaderTableViewCell else { return UITableViewCell() }
            cell.setup(text: category.name, buttonText: R.showMore)
            return cell
        } else if indexPath.row == R.maxPacksShown + 1 {
            // Button cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.buttonCellID, for: indexPath) as? ButtonTableViewCell else { return UITableViewCell() }
            cell.setup(title: R.showMore)
            return cell
        } else if let packs = category.result {
            // Pack cell
            let pack = packs[indexPath.row - 1] // -1: Without header
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.packCellID, for: indexPath) as? StickerPackTableViewCell else { return UITableViewCell() }
            cell.setup(title: pack.name ?? Rc.noNameMessage, detailText: ownershipDescription(name: pack.ownerName, id: pack.owner ?? ""), galleryImages: pack.getStickerImages())
            
            cell.setPropertyValue(category.propertyStr(pack))
            
            return cell
        } else {
            // Loading cell
            return tableView.dequeueReusableCell(withIdentifier: R.loadingCellID, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let category = R.categories[indexPath.section]
        if let packs = category.result,
            indexPath.row - 1 < min(packs.count, R.maxPacksShown) && indexPath.row - 1 >= 0 {
            let pack = packs[indexPath.row - 1]
            performSegue(withIdentifier: R.toEditPackSegueID, sender: pack)
        } else if (indexPath.row == 0) ||
            (indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 && category.result != nil) {
            performSegue(withIdentifier: R.toCategorySegueID, sender: category)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44))
        footerView.backgroundColor = .clear
        return footerView
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.toEditPackSegueID,
            let dvc = segue.destination as? EditPackDBVC,
            let pack = sender as? StickerPackDB {
            dvc.stickerPack = pack
            dvc.isEditingMode = false
        } else if segue.identifier == R.toCategorySegueID,
            let dvc = segue.destination as? WorldCategoryVC,
            let cat = sender as? QueryCategory {
            
            let catWithoutResult = QueryCategory(name: cat.name, getPacks: cat.getPacks, propertyStr: cat.propertyStr, result: nil)
            dvc.category = catWithoutResult
        }
    }
}
