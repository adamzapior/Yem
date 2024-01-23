//
//  PickerButtonWithIconCell.swift
//  Yem
//
//  Created by Adam Zapiór on 11/12/2023.
//

import UIKit

protocol PickerWithIconRowDelegate: AnyObject {
    func pickerWithIconRowTappped(_ cell: PickerWithIconRow)
}

class PickerWithIconRow: UIView {
    weak var delegate: PickerWithIconRowDelegate?
    
    // MARK: - Properties
    
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
    
    convenience init(backgroundColor: UIColor? = UIColor.ui.primaryContainer, iconImage: String, textOnButton: String) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.iconImage = iconImage
        self.icon = IconImage(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
        self.textOnButton.text = textOnButton
        self.textOnButton.textColor = .ui.secondaryText
        
        configure()
    }
    
    // MARK: UI Setup
    
    private func configure() {
        addSubview(icon)
        addSubview(button)
        addSubview(textOnButton)
        
        layer.cornerRadius = 20
        
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        icon.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(18)
            make.width.equalTo(24)
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
    }
    
    // MARK: - Methods
    
    @objc private func buttonTapped() {
        self.onTapAnimation()
        delegate?.pickerWithIconRowTappped(self)
    }
}
