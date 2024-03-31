//
//  IngredientView.swift
//  Yem
//
//  Created by Adam Zapiór on 03/03/2024.
//
//  Reusable view used in RecipeDetailsVC

import SnapKit
import UIKit

final class IngredientView: UIView {
    private let valueLabel = TextLabel(fontStyle: .callout, fontWeight: .regular, textColor: .ui.theme)
    private let nameLabel = TextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.primaryText)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    convenience init(frame: CGRect, iconString: String) {
        self.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, value: String) {
        nameLabel.text = name
        valueLabel.text = value
    }

    func setupUI() {
        addSubview(valueLabel)
        addSubview(nameLabel)

        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        valueLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(valueLabel.snp.trailing).offset(6)
            make.top.equalTo(valueLabel.snp.top)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-6)
        }
    }
}
