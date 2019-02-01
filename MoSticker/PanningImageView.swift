//
//  PanningImageView.swift
//  MoSticker
//
//  Created by Moses Mok on 9/12/2018.
//  Copyright © 2018 Moses Mok. All rights reserved.
//

import UIKit

class PanningImageView: UIImageView {
    var panningStartPoint: CGPoint?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            panningStartPoint = touch.location(in: self)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        panningStartPoint = nil
    }
}
