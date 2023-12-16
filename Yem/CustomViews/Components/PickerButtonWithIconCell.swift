//
//  PickerButtonWithIconCell.swift
//  Yem
//
//  Created by Adam Zapiór on 11/12/2023.
//

import UIKit

protocol PickerButtonWithIconCellDelegate: AnyObject {
    func pickerButtonWithIconCellDidTapButton(_ cell: PickerButtonWithIconCell)
}

class PickerButtonWithIconCell: UIView {
    
    weak var delegate: PickerButtonWithIconCellDelegate?
    
    var icon: IconImageView!
    var iconImage: String
    var textStyle: UIFont.TextStyle
    
    let button = UIButton()
    var textOnButton = UILabel()

    override init(frame: CGRect) {
        // Initialize properties here
        self.iconImage = "plus" // Provide a default icon name
        self.textStyle = .body // Provide a default text style

        super.init(frame: frame)
        self.icon = IconImageView(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(iconImage: String, textOnButton: String) {
        self.init(frame: .zero)
        self.iconImage = iconImage
        self.icon = IconImageView(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
        self.textOnButton.text = textOnButton
        self.textOnButton.textColor = .ui.secondaryText
        
        configure()
    }
    
    private func configure() {
        addSubview(icon)
        addSubview(button)
        addSubview(textOnButton)
        
        layer.cornerRadius = 20
        backgroundColor = .ui.primaryContainer
        
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
    
    @objc private func buttonTapped() {
           delegate?.pickerButtonWithIconCellDidTapButton(self)
       }
}
