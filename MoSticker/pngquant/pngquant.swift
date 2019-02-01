//
//  pngquant.swift
//  pngquant Testing
//
//  Created by Moses Mok on 3/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

extension UIImage {
    func pngquant(_ completion: @escaping (Data?) -> ()) {
        func callCompletion(_ data: Data?) {
            DispatchQueue.main.sync {
                completion(data)
            }
        }
        let queue = DispatchQueue(label: "com.UnqooBB.MM.MoSticker.pngquant")
        queue.async {
            let path = NSTemporaryDirectory()
        
            let oriPath = path + "input.png"
            guard let oriData = self.pngData() else {
                callCompletion(nil)
                return
            }
            do {
                try oriData.write(to: URL(fileURLWithPath: oriPath))
            } catch {
                callCompletion(nil)
                return
            }
            
            let outPath = path + "output.png"
    //            try! FileManager().removeItem(atPath: outPath)

    //            let arg = [oriPath, "--speed", "1", "--force", "--output", outPath]
            pngquant_cli(oriPath, outPath, 1)
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: outPath))
                
                callCompletion(data)
                return
            } catch {
                callCompletion(nil)
                return
            }
        }
    }
}
