import UIKit

protocol TextfieldWithIconCellDelegate: AnyObject {
    func textFieldDidEndEditing(_ cell: TextfieldWithIconCell, didUpdateText text: String)
}

class TextfieldWithIconCell: UIView, UITextFieldDelegate {
    weak var delegate: TextfieldWithIconCellDelegate?
    
    var icon: IconImageView!
    var iconImage: String
    var textStyle: UIFont.TextStyle
    
    let textField = UITextField()
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }

    override init(frame: CGRect) {
        self.iconImage = "plus"
        self.textStyle = .body

        super.init(frame: frame)
        self.icon = IconImageView(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(iconImage: String, placeholderText: String, textColor: UIColor?) {
        self.init(frame: .zero)
        self.iconImage = iconImage
        self.icon = IconImageView(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
                
        let placeholderText = NSAttributedString(string: "\(placeholderText)",
                                                 attributes: [NSAttributedString.Key.foregroundColor: textColor ?? .primaryContainer])
                
        textField.attributedPlaceholder = placeholderText
        
        configure()
    }
    
    private func configure() {
        addSubview(icon)
        addSubview(textField)
        
        layer.cornerRadius = 20
        backgroundColor = .ui.primaryContainer

        textField.delegate = self
        textField.backgroundColor = .ui.primaryContainer
        textField.keyboardType = keyboardType
        
        icon.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.equalToSuperview().offset(18)
            make.width.equalTo(24)
            make.height.equalTo(24)
        }
        
        textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.equalTo(icon.snp.trailing).offset(22)
            make.trailing.equalToSuperview().offset(-9)
        }
    }
    
    // MARK: Delegate textfield

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.textFieldDidEndEditing(self, didUpdateText: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hides the keyboard
        return true
    }
}
