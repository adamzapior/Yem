//
//  IdeaWithIconView.swift
//  Yem
//
//  Created by Adam Zapiór on 06/01/2024.
//

import UIKit

final class SuggestionView: UIView {
    
    var icon: IconImage
    var suggestionText: String
    
    override init(frame: CGRect) {
        self.icon = IconImage(systemImage: "lightbulb.fill", color: .ui.theme, textStyle: .body, contentMode: .center)
        self.suggestionText = ""
        super.init(frame: frame)
        configure()
    }
    
    convenience init(suggestionText: String) {
        self.init(frame: .zero) // Call the designated initializer
        self.suggestionText = suggestionText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        // Configuration code here
    }
}
