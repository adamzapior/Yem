//
//  PickerButtonWithIconCell.swift
//  Yem
//
//  Created by Adam Zapiór on 11/12/2023.
//

import UIKit

protocol AddPickerDelegate: AnyObject {
    func setupDelegate()
    func setupDataSource()
    func setupTag()
    func pickerTapped(item: AddPicker)
}

final class AddPicker: UIView {
    weak var delegate: AddPickerDelegate?
    
    // MARK: - Properties
    
    var minViewHeight: CGFloat?
    
    private var icon: IconImage!
    private var iconImage: String
    private var textStyle: UIFont.TextStyle
    
    private let button = UIButton()
    var textOnButton = UILabel()
    
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
        self.textOnButton.textColor = color

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
        
        textOnButton.snp.makeConstraints { make in
            make.leading.equalTo(button.snp.leading).offset(18)
            make.centerY.equalTo(button.snp.centerY)
        }
        
        self.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(minViewHeight ?? 32)
        }
    }
    
    // MARK: - Delegate methods
    
    @objc private func buttonTapped() {
        self.defaultOnTapAnimation()
        delegate?.pickerTapped(item: self)
    }
}
