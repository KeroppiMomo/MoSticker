//
//  LocalSelectionDelegate.swift
//  MoSticker
//
//  Created by Moses Mok on 16/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

protocol LocalSelectionDelegate {
    func localSelection(_ vc: LocalSelectionVC, didSelect pack: StickerPackLocal)
    func cancelled(_ vc: LocalSelectionVC)
}

// Trick to make Swift protocol function optional without marking @objc:
// https://www.avanderlee.com/swift-2-0/optional-protocol-methods/
extension LocalSelectionDelegate {
    func localSelection(_ vc: LocalSelectionVC, didSelect pack: StickerPackLocal) { }
    func cancelled(_ vc: LocalSelectionVC) { }
}
