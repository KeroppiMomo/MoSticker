//
//  ProfileVC.swift
//  MoSticker
//
//  Created by Moses Mok on 12/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

fileprivate typealias R = Resources.ProVC
class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource, LocalSelectionDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var packs = [StickerPackDB]()
    var displayName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBarItemsEnabled(false)
        updateTableView(isInit: true)
//        StickerPackDB.observe(self.observe)
        StickerPackDB.observeUserPacks { (error, packs) in
            if let packs = packs {
                self.packs = packs
                self.updateTableView(isInit: false)
            }
        }
        
        StickerPackDB.observeCurrentUserName { (displayName) in
            self.displayName = displayName
            self.updateTableView(isInit: false)
        }
    }
    func updateTableView(isInit: Bool) {
        tableView.reloadSections([0, 1], with: .automatic)
        setBarItemsEnabled(true)
        if StickerPackDB.getUID() == nil {
            tableView.backgroundView = createLabelView(Rc.noAuthLabelText)
            setBarItemsEnabled(false)
        } else if packs.count == 0 {
            tableView.backgroundView = isInit ? createLoadingBackgroundView() : createLabelView(Rc.emptyLabelText)
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func setBarItemsEnabled(_ enabled: Bool) {
        self.navigationItem.leftBarButtonItem?.isEnabled = enabled
        self.navigationItem.rightBarButtonItem?.isEnabled = enabled
    }
    
    func localSelection(_ vc: LocalSelectionVC, didSelect pack: StickerPackLocal) {
        let loadingVC = LoadingVC.setup(withMessage: Rc.uploadingMessage)
        vc.present(loadingVC, animated: true, completion: nil)

        let packDB = pack.toPackDB()
        packDB.lastEdit = Date()
        packDB.upload { (error) in
            self.dismiss(animated: true, completion: nil)
            if let error = error {
                vc.showErrorMessage(title: Rc.uploadPackErrorTitle, message: Rc.uploadPackErrorMessage)
                printError(error)
            }
        }
    }
    func cancelled(_ vc: LocalSelectionVC) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return displayName == nil ? 0 : 1
        case 1:
            return packs.count
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        } else if indexPath.section == 1 {
            return 138
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.textFieldCellID, for: indexPath) as? PropertyEditTableViewCell else { return UITableViewCell() }
            cell.setup(property: R.displayNameProperty, value: displayName)
            cell.textField.addTarget(self, action: #selector(nameTextFieldChanged(sender:)), for: .editingDidEnd)
            return cell
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.packCellID, for: indexPath) as? StickerPackTableViewCell else { return UITableViewCell() }
            let pack = packs[indexPath.row]
            
            let name = (String.isEmpty(pack.name) ? nil : pack.name) ?? Rc.noNameMessage
            let detail = pack.lastEdit == nil ? Rc.noDateMessage : Rc.userDateFormatter.string(from: pack.lastEdit!)
            cell.setup(title: name, detailText: detail, galleryImages: pack.getStickerImages())
            cell.setIndicatorHidden(tableView.isEditing, animated: false)
            cell.imageTapAction = { _ in
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.performSegue(withIdentifier: R.editPackSegueID, sender: packs[indexPath.row])
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing && indexPath.section == 1
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let loadingVC = LoadingVC.setup(withMessage: Rc.removingMessage)
            
            self.packs[indexPath.row].delete(completion: { (error) in
                if let error = error {
                    self.showErrorMessage(title: Rc.removePackErrorTitle, message: Rc.removePackErrorMessage)
                    printError(error)
                }
                self.dismiss(animated: true, completion: nil)
            })
            
            self.present(loadingVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return displayName == nil ? nil : R.displayNameFooter
        case 1:
            return nil
        default:
            return nil
        }
    }
    
    @objc func nameTextFieldChanged(sender: UITextField) {
        let name = sender.text
        guard !String.isEmpty(name) else {
            self.showErrorMessage(title: R.displayNameEmptyTitle, message: R.displayNameEmptyMessage) {
                sender.becomeFirstResponder()
            }
            return
        }
        guard name != displayName else { return }
        
        let loadingVC = LoadingVC.setup(withMessage: R.updatingNameMessage)
        StickerPackDB.updateUserName(name!) { (error) in
            self.dismiss(animated: true, completion: nil)
            self.displayName = name
            
            for i in 0..<self.packs.count {
                self.packs[i].ownerName = name
            }
            
            if let error = error {
                self.showErrorMessage(title: R.changeNameErrorTitle, message: R.changeNameErrorMessage)
                printError(error)
            }
        }
        self.present(loadingVC, animated: true, completion: nil)
    }

    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        tableView.visibleCells.forEach { (cell) in
            guard let cell = cell as? StickerPackTableViewCell else { return }
            cell.setIndicatorHidden(tableView.isEditing, animated: true)
        }
        let newItem = UIBarButtonItem(title: tableView.isEditing ? Rc.done : Rc.edit, style: tableView.isEditing ? .done : .plain, target: self, action: #selector(editPressed(_:)))
        navigationItem.leftBarButtonItem = newItem
        navigationItem.rightBarButtonItem?.isEnabled = !tableView.isEditing
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.selectionSegueID,
            let nav = segue.destination as? UINavigationController,
            let dvc = nav.children.first as? LocalSelectionVC {
            dvc.delegate = self
        } else if segue.identifier == R.editPackSegueID,
            let dvc = segue.destination as? EditPackDBVC,
            let pack = sender as? StickerPackDB {
            dvc.stickerPack = pack
            dvc.isEditingMode = false
        }
    }
}
