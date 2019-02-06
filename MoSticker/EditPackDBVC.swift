//
//  EditPackDBVC.swift
//  MoSticker
//
//  Created by Moses Mok on 20/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

class EditPackDBVC: UIViewController, UITableViewDelegate, UITableViewDataSource, PEDelegate {
    
    var stickerPack = StickerPackDB()
    
    // MARK: - Variable declartion
    var _isEditingMode = true
    var isEditingMode: Bool {
        get { return _isEditingMode }
        set {
            navigationItem.setLeftBarButtonItems(newValue ? [cancelButton] : [], animated: true)
            navigationItem.setRightBarButtonItems([newValue ? doneButton : editButton], animated: true)
            
            if _isEditingMode == newValue {
                tableView?.reloadData()
            } else {
                _isEditingMode = newValue
                
                if #available(iOS 11.0, *) {
                    tableView?.performBatchUpdates({
                        if newValue {
                            tableView?.insertRows(at: [IndexPath(row: 0, section: 2)], with: .fade)
                            tableView?.reloadSections([0, 1, 2], with: .fade)
                            tableView?.deleteSections([3], with: .fade)
                        } else {
                            tableView?.deleteRows(at: [IndexPath(row: 0, section: 2)], with: .fade)
                            tableView?.reloadSections([0, 1, 2], with: .fade)
                            tableView?.insertSections([3], with: .fade)
                        }
                    }, completion: { _ in
                        self.tableView?.reloadData()
                    })
                } else {
                    tableView?.beginUpdates()
                    if newValue {
                        tableView?.insertRows(at: [IndexPath(row: 0, section: 2)], with: .fade)
                        tableView?.reloadSections([0, 1, 2], with: .fade)
                        tableView?.deleteSections([3], with: .fade)
                    } else {
                        tableView?.deleteRows(at: [IndexPath(row: 0, section: 2)], with: .fade)
                        tableView?.reloadSections([0, 1, 2], with: .fade)
                        tableView?.insertSections([3], with: .fade)
                    }
                    tableView?.endUpdates()
                }
            }
        }
    }
    
    // MARK: - IBOutlet declartion
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var doneButton: UIBarButtonItem!
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isEditingMode = _isEditingMode
        
        self.navigationItem.rightBarButtonItem?.isEnabled = (stickerPack.owner == StickerPackDB.getUID())
    }
    
    func pe(didFinish webpData: Data, pngData: Data) {
        self.navigationController?.popToViewController(self, animated: true)
        
        guard let selectedRow = tableView.indexPathForSelectedRow else { return }
        if selectedRow.section == 1 {
            tableView.deselectRow(at: selectedRow, animated: true)
            stickerPack.trayData = pngData
            
            tableView.reloadSections([1], with: .none)
        } else if selectedRow.section == 2 {
            tableView.deselectRow(at: selectedRow, animated: true)
            stickerPack.appendSticker(webPData: webpData, pngData: pngData)
            
            tableView.reloadSections([2], with: .none)
        }
    }
    func peDidCancel() {
        self.navigationController?.popToViewController(self, animated: true)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    // MARK: - Table view config
    // MARK: Number of sections and rows
    func numberOfSections(in tableView: UITableView) -> Int {
        return isEditingMode ? 3 : 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:  return 2
        case 1:  return 1
        case 2:  return isEditingMode ? 2 : 1
        case 3:  return 1
        default: return 0
        }
    }
    
    // MARK: Cell for each row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.EPVCs.DB.propertyCellID, for: indexPath) as? PropertyEditTableViewCell else { return UITableViewCell() }
            var propertyName: String?
            var propertyValue: String?
            switch indexPath.row {
            case 0:     propertyName = R.EPVCs.nameProperty
                        propertyValue = stickerPack.name
            case 1:     propertyName = R.EPVCs.ownerProperty
                        propertyValue = ownershipDescription(name: stickerPack.ownerName, id: stickerPack.owner ?? "")
            default:    break
            }
            cell.setup(property: propertyName, value: propertyValue)
            
            cell.textField.tag = indexPath.row
            cell.textField.removeTarget(self, action: #selector(fieldTextChanged(sender:)), for: .editingDidEnd)
            cell.textField.addTarget(self, action: #selector(fieldTextChanged(sender:)), for: .editingDidEnd)
            cell.textField.isEnabled = isEditingMode
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.EPVCs.DB.imageSelectionCellID, for: indexPath) as? ImageSelectionTableViewCell else { return UITableViewCell() }
            
            cell.setup(property: R.EPVCs.iconProperty, changeText: R.EPVCs.changeIcon, image: stickerPack.getTrayImages())
            cell.changeButtonLabel.isHidden = !isEditingMode
            cell.selectionStyle = isEditingMode ? .default : .none
            return cell
        case 2:
            switch indexPath.row {
            case 0:
                if isEditingMode {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: R.EPVCs.DB.buttonCellID, for: indexPath) as? ButtonTableViewCell else { return UITableViewCell() }
                    cell.setup(title: R.EPVCs.addSticker)
                    return cell
                } else {
                    fallthrough
                }
            case 1:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: R.EPVCs.DB.galleryCellID, for: indexPath) as? GalleryTableViewCell else { return UITableViewCell() }
                
                cell.setup(images: stickerPack.getStickerImages())
                cell.imageTapAction = stickerImagePressed(_:)
                return cell
            default:
                return UITableViewCell()
            }
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.EPVCs.DB.buttonCellID, for: indexPath) as? ButtonTableViewCell else { return UITableViewCell() }
            cell.setup(title: R.EPVCs.sendWhatsApp)
            return cell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return 150
        } else if indexPath.section == 2 && indexPath.row == (isEditingMode ? 1 : 0) {
            return 100
        } else { return 44 }
    }
    @objc func fieldTextChanged(sender: UITextField) {
        if sender.tag == 0 {
            stickerPack.name = sender.text
        }
    }
    
    // MARK: Header and Footer
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if isEditingMode {
            switch section {
            case 0:
                return R.EPVCs.nameIDFooter
            case 1:
                return R.EPVCs.iconFooter
            case 2:
                return R.EPVCs.stickerEditFooter
            default:
                return nil
            }
        } else {
            if section == 2 {
                return R.EPVCs.stickerNonEditFooter
            } else {
                return nil
            }
        }
    }
    
    // MARK: Cell selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditingMode {
            if indexPath.section == 1 && indexPath.row == 0 {
                performSegue(withIdentifier: R.EPVCs.DB.toPECropScrollSegueID, sender: R.EPVCs.trayIconRes)
            } else if indexPath.section == 2 && indexPath.row == 0 {
                performSegue(withIdentifier: R.EPVCs.DB.toPECropScrollSegueID, sender: R.EPVCs.stickerRes)
            }
        } else {
            if indexPath.section == 3 {
                tableView.deselectRow(at: indexPath, animated: true)
                guard stickerValidateUI(WhatsApp: indexPath.row == 0) else { return }
                
                self.stickerWhatsAppUI()
            }
        }
    }
    
    // MARK: - Other methods
    // MARK: Sticker packs functions UI
    func stickerValidateUI(WhatsApp required: Bool) -> Bool {
        if let error = stickerPack.validate(WhatsApp: required) {
            showWhatsAppError(error: error)
            return false
        } else {
            return true
        }
    }
    func stickerWhatsAppUI() {
        // Send to WhatsApp
        do {
            try self.stickerPack.sendToWhatsAppWithStats { (success) in
                self.dismiss(animated: true, completion: nil)
                if !success {
                    self.showErrorMessage(title: R.EPVCs.unknownError, message: R.EPVCs.sendWhatsAppErrorMessage)
                }
            }
        } catch {
            self.showWhatsAppError(error: error)
        }
    }
    
    // MARK: IBActions
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        showPopConfirmation()
    }
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        view.endEditing(true)
        
        if let error = stickerPack.validate(WhatsApp: false) {
            showWhatsAppError(error: error)
            return
        }
        
        stickerPack.lastEdit = Date()
        
        isEditingMode = false
        
        let loadingVC = LoadingVC.setup(withMessage: R.Common.uploadingMessage)
        stickerPack.upload { (error) in
            if let error = error {
                loadingVC.showErrorMessage(title: R.Common.uploadPackErrorTitle, message: R.Common.uploadPackErrorMessage) {
                    self.dismiss(animated: true, completion: nil)
                }
                printError(error)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.present(loadingVC, animated: true, completion: nil)
    }
    @IBAction func editPressed(_ sender: UIBarButtonItem) {
        isEditingMode = true
    }
    
    @objc func stickerImagePressed(_ index: Int) {
        if isEditingMode {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let viewAction = UIAlertAction(title: R.EPVCs.viewStickerAction, style: .default) { _ in
                self.performSegue(withIdentifier: R.EPVCs.DB.toViewImgSegueID, sender: self.stickerPack.getStickerImages()[index])
            }
            let removeAction = UIAlertAction(title: R.EPVCs.removeStickerAction, style: .destructive) { _ in
                let alert = UIAlertController(title: nil, message: R.EPVCs.removeStickerConfirmMessage, preferredStyle: .alert)
                let removeAction = UIAlertAction(title: R.EPVCs.removeStickerAction, style: .destructive, handler: { _ in
                    self.stickerPack.removeSticker(at: index)
                    self.tableView.reloadSections([2], with: .automatic)
                })
                let cancelAction = UIAlertAction(title: R.Common.cancel, style: .cancel, handler: nil)
                
                alert.addAction(removeAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: R.Common.cancel, style: .cancel, handler: nil)
            
            alert.addAction(viewAction)
            alert.addAction(removeAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: R.EPVCs.DB.toViewImgSegueID, sender: self.stickerPack.getStickerImages()[index])
        }
    }
    
    // MARK: Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.EPVCs.DB.toPECropScrollSegueID,
            let dvc = segue.destination as? PECropScrollVC,
            let resolution = sender as? Int {
            dvc.resultResolution = resolution
            dvc.delegate = self
        } else if segue.identifier == R.EPVCs.DB.toViewImgSegueID,
            let dvc = segue.destination as? ViewImgVC,
            let image = sender as? UIImage? {
            
            dvc.image = image
        }
    }
}

