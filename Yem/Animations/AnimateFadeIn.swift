//
//  AnimateFadeIn.swift
//  Yem
//
//  Created by Adam Zapiór on 15/08/2024.
//

import UIKit

extension UIView {
    func animateFadeIn(duration: TimeInterval = 0.5) {
        self.alpha = 0
        UIView.animate(withDuration: duration) {
            self.alpha = 1
        }
    }
}
