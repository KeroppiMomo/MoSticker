//
//  PEColorPickerVC.swift
//  MoSticker
//
//  Created by Moses Mok on 8/2/2019.
//  Copyright © 2019 Moses Mok. All rights reserved.
//

import UIKit

class PEColorPickerVC: UIViewController {
    
    var curColor: UIColor!
    var completion: ((UIColor) -> ())?
    
    @IBOutlet weak var hueSlider: GradientSlider!
    @IBOutlet weak var saturationSlider: GradientSlider!
    @IBOutlet weak var brightnessSlider: GradientSlider!
    @IBOutlet weak var colorPreviewView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colorPreviewView.backgroundColor = curColor
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        curColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        hueSlider.value = hue
        saturationSlider.value = saturation
        brightnessSlider.value = brightness
        
        sliderValueChanged(hueSlider)
    }
    
    @IBAction func sliderValueChanged(_ sender: GradientSlider) {
        // Range: [0, 1]
        let hue = hueSlider.value
        let saturation = saturationSlider.value
        let brightness = brightnessSlider.value
        
        hueSlider.setGradientVaryingHue(saturation: 1, brightness: 1)
        saturationSlider.setGradientVaryingSaturation(hue: hue, brightness: 1)
        brightnessSlider.setGradientVaryingBrightness(hue: hue, saturation: saturation)

        curColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
        colorPreviewView.backgroundColor = curColor
    }
    
    @IBAction func donePressed(_ sender: UIButton) {
        completion?(curColor)
    }
}
