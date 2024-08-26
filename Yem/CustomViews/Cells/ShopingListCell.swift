//
//  ShopingListCell.swift
//  Yem
//
//  Created by Adam Zapiór on 06/03/2024.
//

import UIKit

protocol ShopingListCellDelegate: AnyObject {
    func checklistTapped(in cell: ShopingListCell)
}

class ShopingListCell: UITableViewCell {
    static let id: String = "ShopingListCell"
    
    weak var delegate: ShopingListCellDelegate?
    
    var cellType: ShopingListCellType = .unchecked
    
    private let content: UIView = {
        let view = UIView()
        view.backgroundColor = .ui.primaryContainer
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let valueLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .semibold,
        textColor: .ui.theme
    )
    private let valueTypeLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.secondaryText
    )
    private let ingredientNameLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.primaryText
    )
    
    private lazy var checklistIconString = "circle"
    private lazy var filledCircleIconString = "circle.fill"
    
    private lazy var checklistIcon: IconImage = {
        let icon = IconImage(
            systemImage: checklistIconString,
            color: .red,
            textStyle: .body
        )
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapButtonAction)
        )
        icon.addGestureRecognizer(tapGesture)
        icon.isUserInteractionEnabled = true
        return icon
    }()
    
    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.isUserInteractionEnabled = true // !!
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        switch cellType {
        case .unchecked:
            layer.opacity = 1.0
        case .checked:
            layer.opacity = 0.6
        }
    }
    
    // MARK: UI Setup
    
    func configure(with model: ShopingListModel, type: ShopingListCellType, backgroundColor: UIColor = .ui.primaryContainer) {
        cellType = type
        
        valueLabel.text = model.value
        valueTypeLabel.text = model.valueType.lowercased()
        ingredientNameLabel.text = model.name
        
        // Set background color
        content.backgroundColor = backgroundColor
        
        if model.isChecked {
            checklistIcon.image = UIImage(systemName: filledCircleIconString)
        } else {
            checklistIcon.image = UIImage(systemName: checklistIconString)
        }
    }
    
    private func setupUI() {
        addSubview(content)

        content.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(18)
            make.height.greaterThanOrEqualTo(60)
        }
        
        content.addSubview(valueLabel)
        content.addSubview(valueTypeLabel)
        content.addSubview(ingredientNameLabel)
        content.addSubview(checklistIcon)
        
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(content.snp.leading).offset(24)
            make.top.equalToSuperview().offset(12)
        }
        
        valueTypeLabel.snp.makeConstraints { make in
            make.leading.equalTo(valueLabel.snp.trailing).offset(4)
            make.top.equalToSuperview().offset(12)
            make.width.greaterThanOrEqualTo(84)
        }
        
        ingredientNameLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(8)
            make.leading.equalTo(content.snp.leading).offset(24)
            make.bottom.equalToSuperview().inset(12)
            make.width.greaterThanOrEqualTo(36)
        }
        
        checklistIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc func didTapButtonAction() {
        let currentImage = checklistIcon.image
        
        if currentImage == UIImage(systemName: checklistIconString) {
            checklistIcon.image = UIImage(systemName: filledCircleIconString)
        } else {
            checklistIcon.image = UIImage(systemName: checklistIconString)
        }
        
        delegate?.checklistTapped(in: self)
    }
}

enum ShopingListCellType {
    case unchecked
    case checked
}
