//
//  cwebp wrapper.swift
//  webp Testing
//
//  Created by Moses Mok on 5/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

extension UIImage {
    func webpData(targetSize: Int, progressHandler: @escaping (Float) -> (), completion: @escaping (Data?) -> ()) {
        func callCompletion(_ data: Data?) {
            DispatchQueue.main.sync {
                completion(data)
            }
        }
        
        var pipeHasStopped = false
        
        // Open Console Pipe: https://medium.com/@thesaadismail/eavesdropping-on-swifts-print-statements-57f0215efb42
        let inputPipe = Pipe(), outputPipe = Pipe()
        let pipeReadHandle = inputPipe.fileHandleForReading
        dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        
        let progressRegex = try! NSRegularExpression(pattern: "^\\[.{0,}\\/tmp\\/input\\.png\\]:\\s\\s[0-9\\s]{2} %$")
        NotificationCenter.default.addObserver(forName: FileHandle.readCompletionNotification, object: pipeReadHandle, queue: .main) { notification in
            pipeReadHandle.readInBackgroundAndNotify()

            if let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data,
                let str = String(data: data, encoding: .ascii)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                
                guard !pipeHasStopped else {
                    outputPipe.fileHandleForWriting.write(data)
                    return
                }
                
                let strRange = NSRange(location: 0, length: str.count)
                guard progressRegex.matches(in: str, options: [], range: strRange).count == 1,
                    let progress = Int(
                        str.suffix(4).prefix(2).trimmingCharacters(in: .whitespacesAndNewlines)
                    ) else {
                    return
                }
                let finallizedProgress = sqrt(Float(progress) / 100)
                
                progressHandler(finallizedProgress)
            }
        }
        pipeReadHandle.readInBackgroundAndNotify()
        
        
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
            cwebp_wrapper(inputPath, outputPath, Int32(targetSize) / 2)
            
            pipeHasStopped = true
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
