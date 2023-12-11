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

    override init(frame: CGRect) {
        // Inicjalizacja właściwości
        self.iconImage = "plus" // Domyślna nazwa ikony
        self.textStyle = .body // Domyślny styl tekstu

        super.init(frame: frame)
        self.icon = IconImageView(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(iconImage: String, placeholderText: String) {
        self.init(frame: .zero)
        self.iconImage = iconImage
        self.icon = IconImageView(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
        self.textField.placeholder = placeholderText
    }
    
    private func configure() {
        addSubview(icon)
        addSubview(textField)
        
        layer.cornerRadius = 20
        backgroundColor = .ui.primaryContainer

        textField.delegate = self // Ustawienie self jako delegata UITextField
        textField.borderStyle = .roundedRect
        
        // ... (reszta konfiguracji i ograniczeń)
    }

    // Implementacja metody UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.textFieldDidEndEditing(self, didUpdateText: text)
        }
    }
}
