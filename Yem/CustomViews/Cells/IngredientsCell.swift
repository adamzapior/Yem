//
//  IngredientsCell.swift
//  Yem
//
//  Created by Adam Zapiór on 16/12/2023.
//

import UIKit
import Combine

final class IngredientsCell: UITableViewCell {
    static let id: String = "IngredientsCell"
        
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
    
    private lazy var trashIcon: IconImage = {
        let icon = IconImage(
            systemImage: "trash",
            color: .ui.deleteActionColor,
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
    
    // MARK: Combine properties
        
    /// Publisher store
    var eventPublisher: AnyPublisher<Void, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    /// Publisher
    private let eventSubject = PassthroughSubject<Void, Never>()
    
    var cancellables = Set<AnyCancellable>()
        
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

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }
    
    // MARK: UI Setup
    
    func configure(with model: IngredientModel) {
        valueLabel.text = model.value
        valueTypeLabel.text = model.valueType.name.lowercased()
        ingredientNameLabel.text = model.name
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
        content.addSubview(trashIcon)
        
        valueLabel.snp.makeConstraints { make in
            make.leading.equalTo(content.snp.leading).offset(24)
            make.top.equalToSuperview().offset(12)
        }
        
        valueTypeLabel.snp.makeConstraints { make in
            make.leading.equalTo(valueLabel.snp.trailing).offset(6)
            make.top.equalToSuperview().offset(12)
            make.width.greaterThanOrEqualTo(84)
        }
        
        ingredientNameLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(8)
            make.leading.equalTo(content.snp.leading).offset(24)
            make.trailing.equalTo(trashIcon.snp.leading).offset(-12)
            make.bottom.equalToSuperview().inset(12)
            make.width.greaterThanOrEqualTo(36)
        }
        
        trashIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(18.VAdapted)
            make.width.equalTo(22.HAdapted)
        }
    }
    
    @objc func didTapButtonAction() {
        eventSubject.send(())
    }
}
