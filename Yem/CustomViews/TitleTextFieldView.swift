//
//  TitleTextFieldView.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import UIKit

class TitleTextFieldView: UIView {
    
    var textFieldString: String?

    let titleTextField = UITextField()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(textFieldString: String) {
        self.init(frame: .zero)
        self.textFieldString = textFieldString
        titleTextField.text = textFieldString
    }

    private func setupUI() {
        backgroundColor = .ui.primaryContainer
        layer.cornerRadius = 20
//        layer.borderColor = CGColor(red: 255.0/255.0, green: 127.0/255.0, blue: 80.0/255.0, alpha: 1.0)
//        layer.borderWidth = 1.0
//        
        addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(4)
            make.leading.equalTo(self.snp.leading).offset(12)
            make.trailing.equalTo(self.snp.trailing).offset(-12)
            make.bottom.equalTo(self.snp.bottom).offset(-4)

        }
        
        let redPlaceholderText = NSAttributedString(string: "Enter your title name",
                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.ui.secondaryText as Any])
        
        titleTextField.attributedPlaceholder = redPlaceholderText
        titleTextField.textColor = .ui.primaryText
//        titleTextField.backgroundColor = .gray
        titleTextField.layer.cornerRadius = 20
    }
}
