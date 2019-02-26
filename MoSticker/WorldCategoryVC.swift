//
//  WorldCategoryVC.swift
//  MoSticker
//
//  Created by Moses Mok on 19/2/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

fileprivate typealias R = Resources.WoVC.Cat
fileprivate typealias Rs = Resources.WoVC // s = superclass
class WorldCategoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var category: QueryCategory!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = category.name
        tableView.backgroundView = createLoadingBackgroundView()
        tableView.rowHeight = 186
        category.getPacks(Rc.queryItemNo) { (error, packs) in
            if let error = error {
                self.showErrorMessage(title: Rs.queryErrorTitle, message: Rs.queryErrorMessage)
                printError(error)
                return
            }
            guard let packs = packs else { return }
            self.tableView.backgroundView = nil
            self.category.result = packs
            self.tableView.reloadSections([0], with: .automatic)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category.result?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.packCellID, for: indexPath) as? StickerPackTableViewCell else { return UITableViewCell() }
        guard let pack = category.result?[indexPath.row] else { return UITableViewCell() }
        cell.setup(title: pack.name, detailText: ownershipDescription(name: pack.ownerName, id: pack.owner ?? ""), galleryImages: pack.getStickerImages())
        cell.setPropertyValue(category.propertyStr(pack))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let pack = category.result?[indexPath.row] else { return }
        performSegue(withIdentifier: R.toEditPackSegueID, sender: pack)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.toEditPackSegueID,
            let dvc = segue.destination as? EditPackDBVC,
            let pack = sender as? StickerPackDB {
            dvc.stickerPack = pack
            dvc.isEditingMode = false
        }
    }
}
