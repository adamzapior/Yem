//
//  NoteWithIconRow.swift
//  Yem
//
//  Created by Adam Zapiór on 21/01/2024.
//

import UIKit

protocol AddNoteDelegate: AnyObject {
    func textFieldDidBeginEditing(_ textfield: AddNote, didUpdateText text: String)
    func textFieldDidChange(_ textfield: AddNote, didUpdateText text: String)
    func textFieldDidEndEditing(_ textfield: AddNote, didUpdateText text: String)
}

final class AddNote: UIView {
    weak var delegate: AddNoteDelegate?
    
    private var icon: IconImage!
    private var iconImage: String
    private var nameOfRow = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.primaryText
    )
    private var nameOfRowText: String
    private var textStyle: UIFont.TextStyle
    private var placeholder = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.secondaryText
    )
    
    lazy var textField: UITextView = {
        let text = UITextView()
        text.backgroundColor = .ui.secondaryContainer
        text.keyboardType = keyboardType
        return text
    }()
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }
    
    override init(frame: CGRect) {
        self.iconImage = "plus"
        self.textStyle = .body
        self.nameOfRowText = ""

        super.init(frame: frame)
        self.icon = IconImage(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(
        nameOfRowText: String,
        iconImage: String,
        placeholderText: String,
        textColor: UIColor?
    ) {
        self.init(frame: .zero)
        self.nameOfRowText = nameOfRowText
        self.iconImage = iconImage
        self.icon = IconImage(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
                
        let placeholderText = NSAttributedString(
            string: "\(placeholderText)",
            attributes: [NSAttributedString.Key.foregroundColor: textColor ?? .primaryContainer]
        )
                
        configure()
    }
    
    private func configure() {
        addSubview(icon)
        addSubview(nameOfRow)
        addSubview(textField)
        addSubview(placeholder)
        
        layer.cornerRadius = 20
        backgroundColor = .ui.secondaryContainer

        icon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(18)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        nameOfRow.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerY.equalTo(icon)
            make.leading.equalTo(icon.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-18)
        }
        
        nameOfRow.text = "Instruction"
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(nameOfRow.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-12)
            make.height.greaterThanOrEqualTo(172)
        }
        
        textField.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .regular)
        
        placeholder.snp.makeConstraints { make in
            make.centerX.equalTo(textField)
            make.centerY.equalTo(textField)
        }
        
        placeholder.text = "Enter new step..."
    }
}

extension AddNote: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textFieldDidBeginEditing(self, didUpdateText: textView.text)
    }

    func textViewDidChange(_ textView: UITextView) {
        delegate?.textFieldDidChange(self, didUpdateText: textView.text)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textFieldDidEndEditing(self, didUpdateText: textView.text)
    }
}
