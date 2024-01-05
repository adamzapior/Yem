//
//  IngredientsCell.swift
//  Yem
//
//  Created by Adam Zapiór on 16/12/2023.
//

import UIKit

protocol IngredientsCellDelegate: AnyObject {
    func didTapButton(inCell cell: IngredientsCell)
}

class IngredientsCell: UITableViewCell {
    static let id: String = "IngredientsCell"
    
    weak var delegate: IngredientsCellDelegate?
    
    let content: UIView = {
        let view = UIView()
        view.backgroundColor = .ui.primaryContainer
        view.layer.cornerRadius = 20
        return view
    }()
    
    let valueLabel = ReusableTextLabel(fontStyle: .body, fontWeight: .semibold, textColor: .ui.theme, textAlignment: .center)
    let valueTypeLabel = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.secondaryText)
    let ingredientNameLabel = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.primaryText, textAlignment: .center)
    
    lazy var trashIcon: IconImage = {
        let icon = IconImage(systemImage: "trash", color: .red, textStyle: .body)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapButtonAction))
        icon.addGestureRecognizer(tapGesture)
        icon.isUserInteractionEnabled = true
        return icon
    }()
        
    let button = UIButton()

    var didDelete: ((UITableViewCell) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.isUserInteractionEnabled = true
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
            make.height.greaterThanOrEqualTo(60)
        }
        
        button.setTitleColor(.white, for: .highlighted)
        button.addTarget(self, action: #selector(didTapButtonAction), for: .touchUpInside)
        button.setTitle("Tap", for: .normal)
        content.addSubview(valueLabel)
        content.addSubview(valueTypeLabel)
        content.addSubview(ingredientNameLabel)
        content.addSubview(button)
        
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(content.snp.leading).offset(12)
            make.top.equalToSuperview().inset(12)
            make.width.greaterThanOrEqualTo(36)
        }
        
        valueTypeLabel.snp.makeConstraints { make in
            make.leading.equalTo(valueLabel.snp.trailing).offset(8)
            make.top.equalToSuperview().offset(12)
            make.width.greaterThanOrEqualTo(84)
        }
        
        ingredientNameLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(24)
            make.leading.equalTo(content.snp.leading).offset(12)
            make.bottom.equalToSuperview().inset(12)
            make.width.greaterThanOrEqualTo(36)
        }
        
        button.snp.makeConstraints { make in
            make.leading.equalTo(valueTypeLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-36)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(44)
            make.width.equalTo(44)
        }
    }
    
    @objc func didTapButtonAction() {
        print("button tapped")
        delegate?.didTapButton(inCell: self)
    }
}
