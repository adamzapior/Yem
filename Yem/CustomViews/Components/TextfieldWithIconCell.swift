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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(iconImage: String, placeholderText: String) {
        self.init(frame: .zero)
        self.iconImage = iconImage
        self.icon = IconImageView(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
        self.textField.placeholder = placeholderText
        
        configure()
    }
    
    private func configure() {
        addSubview(icon)
        addSubview(textField)
        
        layer.cornerRadius = 20
        backgroundColor = .ui.primaryContainer

        textField.delegate = self // Ustawienie self jako delegata UITextField
//        textField.borderStyle = .roundedRect
        textField.backgroundColor = .ui.primaryContainer
        
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
//            make.height.greaterThanOrEqualTo(50)
        }
        
        
    }

    // Implementacja metody UITextFieldDelegate
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
