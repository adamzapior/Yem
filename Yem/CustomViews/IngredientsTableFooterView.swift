//
//  IngredientsTableHeaderView.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import UIKit

protocol IngredientsTableFooterViewDelegate: AnyObject {
    func addIconTapped(view: UIView)
}

class IngredientsTableFooterView: UIView {
    weak var delegate: IngredientsTableFooterViewDelegate?

    let screenWidth = UIScreen.main.bounds.width

    private let addIcon = IconImageView(systemImage: "plus", color: .ui.theme, textStyle: .body, contentMode: .scaleAspectFit)
    
    private let addButton = MainAppButton(title: "Add", backgroundColor: .ui.addBackground!)
    private let editButton = MainAppButton(title: "Edit", backgroundColor: .ui.primaryContainer!)
    
    private let content = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setEditButtonVisible(_ isVisible: Bool) {
        editButton.isHidden = !isVisible
    }

    

    private func configure() {
        
        addSubview(content)
        content.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        content.addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(50)
            make.width.greaterThanOrEqualTo(350)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addIconTapped))
        addButton.addGestureRecognizer(tapGesture)
        addButton.isUserInteractionEnabled = true
        
        
        content.addSubview(editButton)
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(50)
            make.width.greaterThanOrEqualTo(350)
        }
    }
}

extension IngredientsTableFooterView: IngredientsTableFooterViewDelegate {
    @objc func addIconTapped(view: UIView) {
        delegate?.addIconTapped(view: self)
    }
}
