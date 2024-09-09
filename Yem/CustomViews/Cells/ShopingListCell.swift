//
//  ShopingListCell.swift
//  Yem
//
//  Created by Adam Zapiór on 06/03/2024.
//

import Combine
import UIKit

class ShopingListCell: UITableViewCell {
    static let id: String = "ShopingListCell"
    
    lazy var cellType: ShopingListCellType = .unchecked
    
    private let content: UIView = {
        let view = UIView()
        view.backgroundColor = .ui.primaryContainer
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let ingredientValueLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .semibold,
        textColor: .ui.theme
    )
    private let ingredientValueTypeLabel = TextLabel(
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
            color: .ui.checkboxColor,
            textStyle: .body
        )
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapChecklistButton)
        )
        icon.addGestureRecognizer(tapGesture)
        icon.isUserInteractionEnabled = true
        return icon
    }()
    
    // MARK: Combine properties
        
    /// Publisher store
    var eventPublisher: AnyPublisher<ShopingListCellEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    /// Publisher
    private let eventSubject = PassthroughSubject<ShopingListCellEvent, Never>()
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.isUserInteractionEnabled = true
        setupUI()
        adjustCheckListIconSize()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
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
        
        ingredientValueLabel.text = model.value
        ingredientValueTypeLabel.text = model.valueType.lowercased()
        ingredientNameLabel.text = model.name
        
        // Set background color
        content.backgroundColor = backgroundColor
        
        if model.isChecked {
            checklistIcon.image = UIImage(systemName: filledCircleIconString)
        } else {
            checklistIcon.image = UIImage(systemName: checklistIconString)
        }
        
        setupAccessibilityForChecklistIcon()
        updateAccessibilityValueAndHint(for: checklistIcon, state: cellType)
    }
    
    private func setupUI() {
        addSubview(content)
        
        content.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(18)
        }
        
        content.addSubview(checklistIcon)
        content.addSubview(ingredientValueLabel)
        content.addSubview(ingredientValueTypeLabel)
        content.addSubview(ingredientNameLabel)
        
        ingredientValueLabel.snp.makeConstraints { make in
            make.leading.equalTo(content.snp.leading).offset(24)
            make.top.equalToSuperview().offset(12)
            make.trailing.equalTo(ingredientValueTypeLabel.snp.leading).offset(-6)
        }
       
        ingredientValueTypeLabel.snp.makeConstraints { make in
            make.leading.equalTo(ingredientValueLabel.snp.trailing).offset(6)
            make.trailing.equalTo(checklistIcon.snp.leading).offset(-12)
            make.top.equalToSuperview().offset(12)
            make.width.greaterThanOrEqualTo(84)
        }

        ingredientNameLabel.snp.makeConstraints { make in
            make.top.equalTo(ingredientValueLabel.snp.bottom).offset(8)
            make.top.equalTo(ingredientValueTypeLabel.snp.bottom).offset(8)
        
            make.leading.equalTo(content.snp.leading).offset(24)
            make.trailing.equalTo(checklistIcon.snp.leading).offset(-12)
            make.bottom.equalToSuperview().inset(12)
            make.width.greaterThanOrEqualTo(36)
        }
        
        checklistIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(18.VAdapted)
            make.width.equalTo(22.HAdapted)
        }
        
        ingredientValueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        ingredientValueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        ingredientValueLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        ingredientValueLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        ingredientValueTypeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        ingredientValueTypeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        ingredientValueTypeLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        ingredientValueTypeLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    
        ingredientNameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        ingredientNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private func adjustCheckListIconSize() {
        let categorySize = UIApplication.shared.preferredContentSizeCategory
    
        let size: CGSize
        switch categorySize {
        case .large, .medium, .small:
            size = CGSize(width: 22.HAdapted, height: 18.VAdapted)
        case .extraLarge:
            size = CGSize(width: 22.HAdapted, height: 18.VAdapted)
        case .extraExtraLarge:
            size = CGSize(width: 30.HAdapted, height: 26.VAdapted)
        case .extraExtraExtraLarge:
            size = CGSize(width: 32.HAdapted, height: 28.VAdapted)
        case .accessibilityMedium, .accessibilityLarge, .accessibilityExtraLarge, .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
            size = CGSize(width: 34.HAdapted, height: 30.VAdapted)
        default:
            size = CGSize(width: 22.HAdapted, height: 18.VAdapted)
        }
    
        checklistIcon.snp.updateConstraints { make in
            make.size.equalTo(size)
        }
    
        layoutIfNeeded()
    }
    
    private func setupAccessibilityForChecklistIcon() {
        checklistIcon.isAccessibilityElement = true
        checklistIcon.accessibilityLabel = "Checklist button"
        checklistIcon.accessibilityTraits = .none /// delete default traits
        updateAccessibilityValueAndHint(for: checklistIcon, state: cellType)
    }

    private func updateAccessibilityValueAndHint(for icon: UIImageView, state: ShopingListCellType) {
        icon.accessibilityValue = state == .unchecked
            ? "Item is marked as to buy"
            : "Item is marked as bought"
        icon.accessibilityHint = state == .unchecked
            ? "Mark as checked"
            : "Mark as unchecked"
    }

    @objc func didTapChecklistButton() {
        let currentImage = checklistIcon.image
        
        if currentImage == UIImage(systemName: checklistIconString) {
            checklistIcon.image = UIImage(systemName: filledCircleIconString)
        } else {
            checklistIcon.image = UIImage(systemName: checklistIconString)
        }
        
        updateAccessibilityValueAndHint(for: checklistIcon, state: cellType)
        eventSubject.send(.checklistIconTapped)
    }
}

enum ShopingListCellType {
    case unchecked
    case checked
}

enum ShopingListCellEvent {
    case checklistIconTapped
}
