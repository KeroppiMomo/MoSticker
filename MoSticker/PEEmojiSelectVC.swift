//
//  PEEmojiSelectVC.swift
//  MoSticker
//
//  Created by Moses Mok on 9/2/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit
import ISEmojiView

class PEEmojiSelectVC: UIViewController, EmojiViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    var completion: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emojiView = EmojiView(keyboardSettings: KeyboardSettings(bottomType: .categories))
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
        textView.inputView = emojiView
        
        textView.becomeFirstResponder()
    }
    
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        textView.text = emoji
        doneButton.isEnabled = true
    }
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        textView.text = ""
        doneButton.isEnabled = false
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        completion?(textView.text)
    }
}
