//
//  PEToolOptVC.swift
//  MoSticker
//
//  Created by Moses Mok on 16/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit

class PEToolOptVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var curOptions: PEToolOptions!
    var delegate: PEToolOptVCDelegate!
    
    var isSectionsExpanded = [false, false]
    let tableViewContent: DictionaryLiteral<String, [String]> = [
        "Brush & Eraser Options": ["Brush Size", "Brush Color"],
        "Text Options": ["Text"]
    ]
    
    static let EXPAND_CELL_ID = "expandCell"
    static let SLIDER_CELL_ID = "sliderCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 44
        curOptions = delegate.options(self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSectionsExpanded[section] {
            if section == 0 { return 3 }
            else if section == 1 { return 2 }
            else { return 0 }
        } else { return 1 }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PEToolOptVC.EXPAND_CELL_ID, for: indexPath) as? ExpandTableViewCell else { return UITableViewCell() }
            let content = tableViewContent[indexPath.section].key
            let isExpanded = isSectionsExpanded[indexPath.section]
            cell.setup(isTitle: true, isExpanded: isExpanded, text: content)
            
            return cell
        } else {
            let text = tableViewContent[indexPath.section].value[indexPath.row - 1]
            
            if indexPath.section == 0 && indexPath.row == 1 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: PEToolOptVC.SLIDER_CELL_ID, for: indexPath) as? SliderTableViewCell else { return UITableViewCell() }
                cell.setup(text: text, sliderValue: curOptions.brushSize)
                
                return cell
            }
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            isSectionsExpanded[indexPath.section].toggle()
            tableView.reloadSections([indexPath.section], with: .none)
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}
