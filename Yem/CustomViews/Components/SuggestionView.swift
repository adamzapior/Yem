//
//  IdeaWithIconView.swift
//  Yem
//
//  Created by Adam Zapiór on 06/01/2024.
//

import UIKit

final class SuggestionView: UIView {
    
    private let content: UIView = {
        let view = UIView()
        view.backgroundColor = .ui.primaryContainer
        view.layer.cornerRadius = 20
        return view
    }()

    let icon = IconImage(systemImage: "lightbulb.fill", color: .ui.theme, textStyle: .body, contentMode: .center)
    var suggestionText = ReusableTextLabel(fontStyle: .body, fontWeight: .light, textColor: .primaryText)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(text: String) {
        self.init(frame: .zero)
        self.suggestionText.text = text
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        addSubview(content)
        content.addSubview(icon)
        content.addSubview(suggestionText)
        
        content.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(18)
            make.height.greaterThanOrEqualTo(60)
        }
        
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        suggestionText.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.equalTo(icon.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-12)
        }
    }
}
