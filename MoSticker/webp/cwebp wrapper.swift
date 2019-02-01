//
//  cwebp wrapper.swift
//  webp Testing
//
//  Created by Moses Mok on 5/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

extension UIImage {
    func webpData(targetSize: Int, completion: @escaping (Data?) -> ()) {
        func callCompletion(_ data: Data?) {
            DispatchQueue.main.sync {
                completion(data)
            }
        }
        
        let queue = DispatchQueue(label: "com.UnqooBB.MM.MoSticker.webp")
        queue.async {
            let inputPath = NSTemporaryDirectory() + "input.png"
            guard let inputData = self.pngData() else {
                callCompletion(nil)
                return
            }
            do {
                try inputData.write(to: URL(fileURLWithPath: inputPath))
            } catch {
                callCompletion(nil)
                return
            }
        
            let outputPath = NSTemporaryDirectory() + "output.webp"
            cwebp_wrapper(inputPath, outputPath, Int32(targetSize))
            
            do {
                callCompletion(try Data(contentsOf: URL(fileURLWithPath: outputPath)))
                return
            } catch {
                callCompletion(nil)
                return
            }
        }
    }
}
