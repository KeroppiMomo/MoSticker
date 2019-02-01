//
//  HomeVC.swift
//  MoSticker
//
//  Created by Moses Mok on 29/11/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var packs = [StickerPackLocal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        reloadTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTableView()
    }
    func reloadTableView() {
        do {
            packs = try StickerPackLocal.getAllPacks()
        } catch {
            printError(error)
        }
        tableView.reloadSections([0], with: .none)
        if packs.count == 0 {
            tableView.backgroundView = createLabelView(R.Helper.emptyLabelText)
            if tableView.isEditing {
                editPressed(UIBarButtonItem())
            }
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.HoVC.packCellID, for: indexPath) as? StickerPackTableViewCell else { return UITableViewCell() }
        let pack = packs[indexPath.row]
        
        let name = (pack.name == "" ? nil : pack.name) ?? R.Common.noNameMessage
        let detail = pack.lastEdit == nil ? R.Common.noDateMessage : R.Common.userDateFormatter.string(from: pack.lastEdit!)
        cell.setup(title: name, detailText: detail, galleryImages: pack.getStickerImages())
        cell.setIndicatorHidden(tableView.isEditing, animated: false)
        cell.imageTapAction = { _ in
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: R.HoVC.cellToEditPackSegueID, sender: packs[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = UIAlertController(title: nil, message: R.Common.removePackConfirmMessage, preferredStyle: .alert)
            let removeAction = UIAlertAction(title: R.Common.removePackAction, style: .destructive, handler: { _ in
                
                do {
                    try self.packs[indexPath.row].deletePack()
                    self.reloadTableView()
                } catch {
                    self.showErrorMessage(title: R.Common.removePackErrorTitle, message: R.Common.removePackErrorMessage)
                    printError(error)
                }
            })
            let cancelAction = UIAlertAction(title: R.Common.cancel, style: .cancel, handler: nil)
            
            alert.addAction(removeAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        tableView.visibleCells.forEach { (cell) in
            guard let cell = cell as? StickerPackTableViewCell else { return }
            cell.setIndicatorHidden(tableView.isEditing, animated: true)
        }
        let newItem = UIBarButtonItem(title: tableView.isEditing ? R.Common.done : R.Common.edit, style: tableView.isEditing ? .done : .plain, target: self, action: #selector(editPressed(_:)))
        navigationItem.leftBarButtonItem = newItem
        navigationItem.rightBarButtonItem?.isEnabled = !tableView.isEditing
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.HoVC.addToEditPackSegueID,
            let dvc = segue.destination as? EditPackLocalVC {
            let stickerPack = StickerPackLocal()
            stickerPack.savingID = try? StickerPackLocal.generateID()
            dvc.stickerPack = stickerPack
            dvc.isEditingMode = true
        } else if segue.identifier == R.HoVC.cellToEditPackSegueID,
            let dvc = segue.destination as? EditPackLocalVC,
            let pack = sender as? StickerPackLocal {
            dvc.stickerPack = pack
            dvc.isEditingMode = false
        }
    }
}

