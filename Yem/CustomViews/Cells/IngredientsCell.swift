//
//  IngredientsCell.swift
//  Yem
//
//  Created by Adam Zapiór on 16/12/2023.
//

import UIKit

class IngredientsCell: UITableViewCell {
    static let id: String = "IngredientsCell"
    
    let content: UIView = {
        let view = UIView()
        view.backgroundColor = .ui.primaryContainer
        view.layer.cornerRadius = 20
        return view
    }()
    
    let valueLabel = ReusableTextLabel(fontStyle: .body, fontWeight: .semibold, textColor: .ui.theme, textAlignment: .center)
    let valueTypeLabel = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.secondaryText)
    let ingredientNameLabel = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.primaryText)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with model: IngredientModel) {
        valueLabel.text = model.value
        valueTypeLabel.text = model.valueType
        ingredientNameLabel.text = model.name
    }
    
    private func setupUI() {
        addSubview(content)

        content.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.greaterThanOrEqualTo(50)
        }
        
        content.addSubview(valueLabel)
        content.addSubview(valueTypeLabel)
        content.addSubview(ingredientNameLabel)
        
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(content).offset(12)
            make.top.bottom.equalToSuperview().inset(12)
            make.width.greaterThanOrEqualTo(36)
        }
        
        valueTypeLabel.snp.makeConstraints { make in
            make.leading.equalTo(valueLabel.snp.trailing).offset(8)
            make.centerY.equalTo(valueLabel)
            make.width.greaterThanOrEqualTo(84)
        }
        
        ingredientNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(valueTypeLabel.snp.trailing).offset(8)
            make.centerY.equalTo(valueLabel)
        }
    }
}
