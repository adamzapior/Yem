//
//  ColorTheme.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Foundation
import UIKit

struct ColorTheme {
    var background = UIColor.systemBackground
    var theme = UIColor.systemOrange
    var primaryText = UIColor(named: "primaryText")
    var secondaryText = UIColor(named: "secondaryText")
    var primaryContainer = UIColor(named: "primaryContainer")
//    var imageHeaderText = UIColor.white
    var divider = UIColor(named: "divider")
}

extension UIColor {
    static let ui = ColorTheme()
}
