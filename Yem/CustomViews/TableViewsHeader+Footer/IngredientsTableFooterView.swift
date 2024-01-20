//
//  IngredientsTableHeaderView.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import UIKit

protocol IngredientsTableFooterViewDelegate: AnyObject {
    func addIconTapped(view: UIView)
    func editButtonTapped(view: UIView)
}

class IngredientsTableFooterView: UIView {
    weak var delegate: IngredientsTableFooterViewDelegate?

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
            make.bottom.equalToSuperview().offset(-100)
            make.leading.trailing.equalToSuperview()
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
        
        let editTapGesture = UITapGestureRecognizer(target: self, action: #selector(editButtonTapped))
        editButton.addGestureRecognizer(editTapGesture)
        editButton.isUserInteractionEnabled = true
    }
    
    func setEditButtonVisible(_ isVisible: Bool) {
         editButton.isHidden = !isVisible
     }
}

extension IngredientsTableFooterView: IngredientsTableFooterViewDelegate {
    @objc func addIconTapped(view: UIView) {
        self.addButton.onTapAnimation()
        delegate?.addIconTapped(view: self)
        print("worked")
    }
    
    @objc func editButtonTapped(view: UIView) {
        self.editButton.onTapAnimation()
        delegate?.editButtonTapped(view: self)
        print("worked2")

       }

}
