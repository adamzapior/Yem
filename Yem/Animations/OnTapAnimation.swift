//
//  OnTapAnimation.swift
//  Yem
//
//  Created by Adam Zapiór on 27/12/2023.
//

import UIKit

extension UIView {
    func onTapAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform.identity
            }
        }
    }
}

