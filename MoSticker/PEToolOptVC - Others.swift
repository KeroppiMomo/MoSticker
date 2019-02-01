//
//  PEToolOptVCDelegate.swift
//  MoSticker
//
//  Created by Moses Mok on 16/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit

struct PEToolOptions {
    var brushSize: CGFloat = 0.5
    var brushColor: UIColor = UIColor.green
    var textSize: CGFloat = 0.5
}
protocol PEToolOptVCDelegate {
    
    func options(_ toolOpt: PEToolOptVC) -> PEToolOptions
    func toolOpt(_ toolOpt: PEToolOptVC, didFinish options: PEToolOptions)
}
