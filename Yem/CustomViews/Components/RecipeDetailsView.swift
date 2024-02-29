//
//  RecipeDetailsView.swift
//  Yem
//
//  Created by Adam Zapiór on 29/02/2024.
//

import Foundation
import SnapKit
import UIKit

class RecipeDetailsView: UIView {
    private let titleTextLabel = UILabel()
    private let valueTextLabel = UILabel()
    
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
        
//        titleTextLabel.setupHyphenation()
//        titleTextLabel.setupHyphenation()
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
        
        titleTextLabel.numberOfLines = 0
        titleTextLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .regular)
        titleTextLabel.adjustsFontForContentSizeCategory = true
        titleTextLabel.textColor = .ui.secondaryText
        
        titleTextLabel.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(12)
            make.leading.equalTo(self.snp.leading).offset(12)
            make.trailing.equalTo(self.snp.trailing).offset(-12)
        }
    }
    
    private func setupValueTextLabel() {
        addSubview(valueTextLabel)
        
        valueTextLabel.numberOfLines = 0
        valueTextLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        valueTextLabel.adjustsFontForContentSizeCategory = true
        valueTextLabel.textColor = .ui.primaryText
        
        valueTextLabel.snp.makeConstraints { make in
            make.top.equalTo(titleTextLabel.snp.bottom).offset(8)
            make.leading.equalTo(self.snp.leading).offset(12)
            make.trailing.equalTo(self.snp.trailing).offset(-12)
            make.bottom.equalTo(self.snp.bottom).offset(-12)
        }
    }
}
