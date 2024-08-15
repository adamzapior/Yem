//
//  OnTapAnimation.swift
//  Yem
//
//  Created by Adam Zapiór on 27/12/2023.
//

import UIKit

extension UIView {
    func defaultOnTapAnimation() {
        self.transform = CGAffineTransform.identity

        UIView.animate(withDuration: 0.3, animations: {
            self.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.transform = CGAffineTransform.identity
            }
        }
    }
}
