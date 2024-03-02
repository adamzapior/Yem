//
//  HyphenationSetupExt.swift
//  Yem
//
//  Created by Adam Zapiór on 02/03/2024.
//

import UIKit

extension UILabel {
    func setupHyphenation() {
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        self.adjustsFontSizeToFitWidth = false
        self.allowsDefaultTighteningForTruncation = true
        if let text = self.text {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.hyphenationFactor = 0.7
            let attributedString = NSAttributedString(string: text,
                                                      attributes: [.paragraphStyle: paragraphStyle])
            self.attributedText = attributedString
        }
    }
}
