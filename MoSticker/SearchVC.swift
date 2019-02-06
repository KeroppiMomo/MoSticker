//
//  SearchVC.swift
//  MoSticker
//
//  Created by Moses Mok on 28/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [StickerPackDB]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = R.SearVC.barPlaceholder

        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
        
        filter(searching: "")
        tableView.backgroundView = createLoadingBackgroundView()
        
        // To prevent tableView content hiding behind the keyboard
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    func filter(searching text: String) {
        StickerPackDB.query(with: text) { results in
            self.searchResults = results
            self.tableView.reloadSections([0], with: .automatic)
            
            if self.searchResults.count == 0 {
                self.tableView.backgroundView = createLabelView(R.SearVC.noResults)
            } else {
                self.tableView.backgroundView = nil
            }
        }
    }
    @objc func adjustForKeyboard(notification: Notification) {
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = UIEdgeInsets.zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - (self.tabBarController?.tabBar.frame.size.height ?? 0), right: 0)
        }
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filter(searching: searchController.searchBar.text ?? "")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.SearVC.packCellID, for: indexPath) as? StickerPackTableViewCell else { return UITableViewCell() }
        let pack = searchResults[indexPath.row]
        cell.setup(title: pack.name ?? R.Common.noNameMessage, detailText: ownershipDescription(name: pack.ownerName, id: pack.owner ?? ""), galleryImages: pack.getStickerImages())
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let pack = searchResults[indexPath.row]
        performSegue(withIdentifier: R.SearVC.toEditPackSegueID, sender: pack)
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if searchResults.count == 0 {
            return nil
        } else if searchResults.count == 100 {
            return R.SearVC.limitReachedFooter
        } else {
            return R.SearVC.nothingMoreFooter
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.SearVC.toEditPackSegueID,
            let dvc = segue.destination as? EditPackDBVC,
            let pack = sender as? StickerPackDB {
            
            dvc.stickerPack = pack
            dvc.isEditingMode = false
        }
    }
}
