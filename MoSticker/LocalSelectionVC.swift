//
//  LocalSelectionVC.swift
//  MoSticker
//
//  Created by Moses Mok on 16/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

class LocalSelectionVC: HomeVC {
    
    var delegate: LocalSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if packs.count == 0 {
            self.showErrorMessage(title: R.LSVC.emptyTitle, message: R.LSVC.emptyMessage) {
                self.delegate?.cancelled(self)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let pack = packs[indexPath.row]
        if let error = pack.validate(WhatsApp: false) {
            self.showWhatsAppError(error: error)
            return
        }
        delegate?.localSelection(self, didSelect: pack)
    }
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        delegate?.cancelled(self)
    }
}
