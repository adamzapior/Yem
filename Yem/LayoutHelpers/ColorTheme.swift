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
    var primaryText = UIColor(named: "primaryText")!
    var secondaryText = UIColor(named: "secondaryText")!
    var primaryContainer = UIColor(named: "primaryContainer")!
    var secondaryContainer = UIColor(named: "secondaryContainer")!
    var addBackground = UIColor(named: "addBackground")!
    var cancelBackground = UIColor(named: "cancelBackground")!
    var divider = UIColor(named: "divider")!
    var placeholderError = UIColor(named: "placeholderError")!
    var spicyMild = UIColor(named: "spicyMild")!
    var spicyMedium = UIColor(named: "spicyMedium")!
    var spicyHot = UIColor(named: "spicyHot")!
    var spicyVeryHot = UIColor(named: "spicyVeryHot")!
}

extension UIColor {
    static let ui = ColorTheme()
}
