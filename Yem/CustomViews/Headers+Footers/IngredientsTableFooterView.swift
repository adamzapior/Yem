//
//  IngredientsTableHeaderView.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import UIKit

protocol IngredientsTableFooterViewDelegate: AnyObject {
    func addIconTapped(view: UIView)
}

final class IngredientsTableFooterView: UIView {
    weak var delegate: IngredientsTableFooterViewDelegate?

    private let screenWidth = UIScreen.main.bounds.width

    private let addButton = ActionButton(title: "Add", backgroundColor: .ui.addBackground)

    private let content = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        configureComponents()
        configureTags()
        configureDelegateAndDataSource()
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
    }
}

// MARK: - Delegate & data source items

extension IngredientsTableFooterView: ActionButtonDelegate {
    func actionButtonTapped(_ button: ActionButton) {
        switch button.tag {
        case 1:
            button.onTapAnimation()
            delegate?.addIconTapped(view: self)
        default:
            break
        }
    }

    private func configureComponents() {
        configureTags()
        configureDelegateAndDataSource()
    }

    private func configureTags() {
        /// mainButton:
        addButton.tag = 1
    }

    private func configureDelegateAndDataSource() {
        /// mainButton:
        addButton.delegate = self
    }
}
