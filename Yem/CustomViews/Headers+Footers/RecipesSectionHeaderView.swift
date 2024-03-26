//
//  RecipesSectionHeaderView.swift
//  Yem
//
//  Created by Adam Zapiór on 26/03/2024.
//

import UIKit

class RecipesSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "RecipesSectionHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        addSubview(titleLabel)
        titleLabel.textColor = .ui.secondaryText

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
