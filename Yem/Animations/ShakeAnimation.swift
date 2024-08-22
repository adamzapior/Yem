//
//  ShakeAnimation.swift
//  Yem
//
//  Created by Adam Zapiór on 22/08/2024.
//

import UIKit

extension UIView {
    func startShaking() {
        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        shakeAnimation.values = [-6.0, 6.0, -6.0, 5.0, -5.0, 5.0, -3.0, 3.0, 0.0]
        shakeAnimation.duration = 0.6
        shakeAnimation.repeatCount = .infinity
        layer.add(shakeAnimation, forKey: "shake")
    }

    func stopShaking() {
        layer.removeAnimation(forKey: "shake")
    }
}
