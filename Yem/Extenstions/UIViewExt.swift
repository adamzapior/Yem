//
//  UIViewExt.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import Foundation
import UIKit

extension UIView {
    static func createDivider(color: UIColor) -> UIView {
        let divider = UIView()
        divider.backgroundColor = color
//        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 5)
        ])
        return divider
    }
}
