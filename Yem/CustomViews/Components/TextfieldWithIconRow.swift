import UIKit

protocol TextfieldWithIconRowDelegate: AnyObject {
    func setupDelegate()
    func setupTag()
    func textFieldDidBeginEditing(_ textfield: TextfieldWithIcon, didUpdateText text: String)
    func textFieldDidChange(_ textfield: TextfieldWithIcon, didUpdateText text: String)
    func textFieldDidEndEditing(_ textfield: TextfieldWithIcon, didUpdateText text: String)
}

final class TextfieldWithIcon: UIView, UITextFieldDelegate {
    weak var delegate: TextfieldWithIconRowDelegate?
    
    private var icon: IconImage!
    private var iconImage: String
    private var textStyle: UIFont.TextStyle
    
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
        self.icon = IconImage(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(backgroundColor: UIColor? = .ui.primaryContainer, iconImage: String, placeholderText: String, textColor: UIColor?) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.iconImage = iconImage
        self.icon = IconImage(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
                
        let placeholderText = NSAttributedString(string: "\(placeholderText)",
                                                 attributes: [NSAttributedString.Key.foregroundColor: textColor ?? .primaryContainer])
                
        textField.attributedPlaceholder = placeholderText
        
        configure()
    }
    
    func setPlaceholderColor(_ color: UIColor) {
           let placeholderText = NSAttributedString(string: textField.placeholder ?? "",
                                                    attributes: [NSAttributedString.Key.foregroundColor: color])
           textField.attributedPlaceholder = placeholderText
       }
    
    private func configure() {
        addSubview(icon)
        addSubview(textField)
        
        layer.cornerRadius = 20
//        backgroundColor = .ui.primaryContainer

        textField.delegate = self
        textField.backgroundColor = backgroundColor
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
        
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    // MARK: Delegate textfield
    
    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.textFieldDidChange(self, didUpdateText: text)
            setPlaceholderColor(.ui.secondaryText ?? .darkGray)
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.textFieldDidBeginEditing(self, didUpdateText: text)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.textFieldDidEndEditing(self, didUpdateText: text)
        }
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        onTapAnimation()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hides the keyboard
        return true
    }
}
