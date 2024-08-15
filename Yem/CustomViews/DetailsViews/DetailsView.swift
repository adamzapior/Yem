//
//  RecipeDetailsView.swift
//  Yem
//
//  Created by Adam Zapiór on 29/02/2024.
//

import Foundation
import SnapKit
import UIKit

class DetailsView: UIView {
    private let titleTextLabel = TextLabel(
        fontStyle: .footnote,
        fontWeight: .semibold,
        textColor: .ui.theme
    )
    private let valueTextLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.primaryText
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(titleText: String, valueText: String) {
        titleTextLabel.text = titleText
        valueTextLabel.text = valueText
        
        titleTextLabel.text = titleTextLabel.text!.uppercased()

        valueTextLabel.setupHyphenation()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.ui.primaryContainer
        layer.cornerRadius = 10
        clipsToBounds = true
        
        setupTitleTextLabel()
        setupValueTextLabel()
    }
    
    private func setupTitleTextLabel() {
        addSubview(titleTextLabel)

        titleTextLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
    }
    
    private func setupValueTextLabel() {
        addSubview(valueTextLabel)

        valueTextLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}
