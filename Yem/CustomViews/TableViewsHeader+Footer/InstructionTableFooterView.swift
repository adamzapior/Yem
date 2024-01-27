//
//  InstructionTableFooterView.swift
//  Yem
//
//  Created by Adam Zapiór on 20/01/2024.
//

import UIKit

protocol InstructionTableFooterViewDelegate: AnyObject {
    func addIconTapped(view: UIView)
}

final class InstructionTableFooterView: UIView {
    weak var delegate: InstructionTableFooterViewDelegate?

    
    private let screenWidth = UIScreen.main.bounds.width
    
    private let addButton = MainActionButton(title: "Add", backgroundColor: .ui.addBackground!)
    private let editButton = MainActionButton(title: "Edit", backgroundColor: .ui.primaryContainer!)
    
    private let content = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
            make.width.greaterThanOrEqualTo(330.HAdapted)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addIconTapped))
        addButton.addGestureRecognizer(tapGesture)
        addButton.isUserInteractionEnabled = true
        
        
        content.addSubview(editButton)
        
        editButton.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.greaterThanOrEqualTo(50)
            make.width.greaterThanOrEqualTo(330.HAdapted)
        }
    }
    
    func setEditButtonVisible(_ isVisible: Bool) {
         editButton.isHidden = !isVisible
     }
}


extension InstructionTableFooterView: InstructionTableFooterViewDelegate {
    @objc func addIconTapped(view: UIView) {
        self.addButton.onTapAnimation()

        delegate?.addIconTapped(view: self)
    }

}
