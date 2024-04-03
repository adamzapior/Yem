//
//  SettingsCell.swift
//  Yem
//
//  Created by Adam Zapiór on 03/04/2024.
//

import UIKit

class SettingsCell: UITableViewCell {
    static let reuseID = "SettingsCell"
    
    private let titleLabel = TextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.primaryText)
    private let image = IconImage(systemImage: "plus", color: .ui.theme, textStyle: .body, contentMode: .center)
    private let arrow = IconImage(systemImage: "chevron.right", color: .ui.secondaryText, textStyle: .body, contentMode: .center)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.isUserInteractionEnabled = true // !!
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(with options: SettingsOption) {
        titleLabel.text = options.title
        image.image = options.icon
    }
    
    private func setupUI() {
        addSubview(image)
        addSubview(titleLabel)
        addSubview(arrow)
        
        image.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.top.bottom.equalToSuperview().inset(18)
            make.width.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(12)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(arrow.snp.leading).offset(-12)
        }
        
        arrow.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-6)
            make.top.bottom.equalToSuperview().inset(18)
            make.width.equalTo(48)
        }
    }
}
