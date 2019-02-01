//
//  pngquant.swift
//  pngquant Testing
//
//  Created by Moses Mok on 3/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

extension UIImage {
    func pngquant() -> Data? {
        let path = NSTemporaryDirectory()
        
        let oriPath = path + "input.png"
        guard let oriData = self.pngData() else { return nil }
        do {
            try oriData.write(to: URL(fileURLWithPath: oriPath))
        } catch {
            return nil
        }
        
        let outPath = path + "output.png"
        pngquant_cli(oriPath, outPath, 1)
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: outPath))
            return data
        } catch {
            return nil
        }
    }
}
