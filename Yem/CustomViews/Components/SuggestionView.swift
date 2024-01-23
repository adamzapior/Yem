//
//  IdeaWithIconView.swift
//  Yem
//
//  Created by Adam Zapiór on 06/01/2024.
//

import UIKit

final class SuggestionView: UIView {
    
    var icon: IconImage
    var suggestionText = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .primaryText)
    
    override init(frame: CGRect) {
        self.icon = IconImage(systemImage: "lightbulb.fill", color: .ui.theme, textStyle: .body, contentMode: .center)
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .ui.primaryContainer
        
        addSubview(icon)
        addSubview(suggestionText)
        
        icon.snp.makeConstraints { make in
            //
        }
        
        suggestionText.snp.makeConstraints { make in
            //
        }
    }
}
