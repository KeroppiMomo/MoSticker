//
//  pngquant.swift
//  pngquant Testing
//
//  Created by Moses Mok on 3/1/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

extension UIImage {
    func pngquant(progressHandler: @escaping (Float) -> Void, _ completion: @escaping (Data?) -> Void) {
        func callCompletion(_ data: Data?) {
            DispatchQueue.main.sync {
                completion(data)
            }
        }
        
        // Open Console Pipe: https://medium.com/@thesaadismail/eavesdropping-on-swifts-print-statements-57f0215efb42
        var pipeHasStopped = false
        
        let inputPipe = Pipe(), outputPipe = Pipe()
        let pipeReadHandle = inputPipe.fileHandleForReading
        dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        
        let progressRegex = try! NSRegularExpression(pattern: "^selecting\\scolors...[0-9]{1,3}%$")
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
                        str.dropFirst(19).dropLast(1).trimmingCharacters(in: .whitespacesAndNewlines)
                        // "selecting colors..." has 21 characters, and "%" has 1 character
                    ) else {
                        return
                }
                let finallizedProgress = Float(progress) / 100
                
                progressHandler(finallizedProgress)
            }
        }
        pipeReadHandle.readInBackgroundAndNotify()
        
        
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
            pngquant_cli(oriPath, outPath, 1)
            pipeHasStopped = true
            
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
