//
//  PickerButtonWithIconCell.swift
//  Yem
//
//  Created by Adam Zapiór on 11/12/2023.
//

import Combine
import UIKit

final class AddPickerView: UIView {
    var textOnButton = UILabel()

    private var minViewHeight: CGFloat?
    private var icon: IconImage!
    private var iconImage: String
    private let textStyle: UIFont.TextStyle
    private let button = UIButton()
            
    /// Publisher store
    var tapPublisher: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    /// Publisher
    private let tapSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        /// default values
        self.iconImage = "plus"
        self.textStyle = .body

        super.init(frame: frame)
        self.icon = IconImage(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(
        minViewHeight: CGFloat? = nil,
        backgroundColor: UIColor? = UIColor.ui.primaryContainer,
        iconImage: String,
        textOnButton: String
    ) {
        self.init(frame: .zero)
        self.minViewHeight = minViewHeight ?? 32
        self.backgroundColor = backgroundColor
        self.iconImage = iconImage
        self.icon = IconImage(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
        self.textOnButton.text = textOnButton
        self.textOnButton.textColor = .ui.secondaryText
        
        configure()
    }
    
    // MARK: UI Setup
    
    func setPlaceholderColor(_ color: UIColor) {
        textOnButton.textColor = color
    }
    
    private func configure() {
        addSubview(icon)
        addSubview(button)
        addSubview(textOnButton)
        
        layer.cornerRadius = 20
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalTo(button.snp.centerY)
            make.width.equalTo(22)
            make.height.equalTo(24)
        }
        
        button.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.equalTo(icon.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(6)
        }
        
        textOnButton.font = UIFont.preferredFont(forTextStyle: .body)
        textOnButton.adjustsFontForContentSizeCategory = true
        textOnButton.maximumContentSizeCategory = .accessibilityLarge
        
        textOnButton.snp.makeConstraints { make in
            make.leading.equalTo(button.snp.leading).offset(18)
            make.centerY.equalTo(button.snp.centerY)
            make.trailing.equalTo(button.snp.trailing).offset(-18)
        }
        
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(minViewHeight ?? 32)
        }
    }
    
    @objc private func buttonTapped() {
        defaultOnTapAnimation()
        tapSubject.send(())
    }
}
