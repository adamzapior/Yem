//
//  IngredientsTableHeaderView.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import UIKit

final class IngredientsTableFooterView: UIView {
    let addButton = ActionButton(
        title: "Add",
        backgroundColor: .ui.addBackground
    )

    private let content = UIView()
    private let screenWidth = UIScreen.main.bounds.width

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configure() {
        addSubview(content)
        content.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
            make.leading.trailing.equalToSuperview()
        }

        content.addSubview(addButton)

        addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(50)
            make.width.greaterThanOrEqualTo(330.HAdapted)
        }

        addButton.animateFadeIn()
    }
}
