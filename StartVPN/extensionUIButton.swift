//
//  extensionUIButton.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 12.03.2021.
//

import UIKit

extension UIButton {
    
    func pulsate(statusConnecting:Bool){
        if statusConnecting == true {
            let pulse = CASpringAnimation(keyPath: "transform.scale")
            pulse.duration = 0.6
            pulse.fromValue = 0.95
            pulse.toValue = 1
            pulse.autoreverses = true
            pulse.repeatCount = .greatestFiniteMagnitude
            pulse.initialVelocity = 0.5
            pulse.damping = 1.0
            layer.add(pulse, forKey: "puls")
        } else {
            layer.removeAnimation(forKey: "puls")
        }
        
    }
}
