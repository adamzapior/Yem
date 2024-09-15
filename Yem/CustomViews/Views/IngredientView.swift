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
    private let contaierView = UIView()
    
    private let valueLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .semibold,
        textColor: .ui.theme
    )
    private let nameLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.primaryText
    )

    // MARK: Lifecycle

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

    // MARK: UI Setup

    func configure(name: String, value: String) {
        nameLabel.text = name
        valueLabel.text = value
    }

    
    func setupUI() {
        addSubview(contaierView)
        contaierView.addSubview(valueLabel)
        contaierView.addSubview(nameLabel)
        
        contaierView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        self.backgroundColor = UIColor.ui.primaryContainer

        valueLabel.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-6)
        }
    }
}
