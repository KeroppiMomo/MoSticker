//
//  PEDelegate.swift
//  MoSticker
//
//  Created by Moses Mok on 16/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit

@objc protocol PEDelegate {
    
    @objc optional func pe(didFinish webpData: Data, pngData: Data)
    @objc optional func peDidCancel()
}
