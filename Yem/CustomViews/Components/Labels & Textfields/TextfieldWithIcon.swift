import UIKit

final class TextfieldWithIcon: UIView, UITextFieldDelegate {
    
    let textField = UITextField()
    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }
    
    var minViewHeight: CGFloat?
    
    private var icon: IconImage!
    private var iconImage: String
    private var textStyle: UIFont.TextStyle
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        self.iconImage = "plus"
        self.textStyle = .body
        
        super.init(frame: frame)
        self.icon = IconImage(
            systemImage: iconImage,
            color: .ui.theme,
            textStyle: textStyle
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(
        minViewHeight: CGFloat? = nil,
        backgroundColor: UIColor? = .ui.primaryContainer,
        iconImage: String,
        placeholderText: String,
        textColor: UIColor?,
        keyboardType: UIKeyboardType = .default
    ) {
        self.init(frame: .zero)
        self.minViewHeight = minViewHeight
        self.backgroundColor = backgroundColor
        self.iconImage = iconImage
        self.icon = IconImage(
            systemImage: iconImage,
            color: .ui.theme,
            textStyle: textStyle,
            contentMode: .scaleAspectFit
        )
        self.keyboardType = keyboardType
        
        let placeholderText = NSAttributedString(
            string: "\(placeholderText)",
            attributes: [NSAttributedString.Key.foregroundColor: textColor ?? .primaryContainer]
        )
        
        textField.attributedPlaceholder = placeholderText
        
        configure()
    }
    
    func setPlaceholderColor(_ color: UIColor) {
        let placeholderText = NSAttributedString(
            string: textField.placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: color]
        )
        textField.attributedPlaceholder = placeholderText
    }
    
    // MARK: UI Setup
    
    private func configure() {
        addSubview(icon)
        addSubview(textField)
        
        layer.cornerRadius = 20
        
        textField.delegate = self
        textField.backgroundColor = backgroundColor
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.keyboardType = keyboardType
        
        icon.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalTo(textField.snp.centerY)
            make.width.equalTo(24.HAdapted)
            make.height.equalTo(24.VAdapted)
        }
        
        textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.equalTo(icon.snp.trailing).offset(22)
            make.trailing.equalToSuperview().offset(-9)
        }
                
        snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(minViewHeight ?? 32)
        }
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        defaultOnTapAnimation()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hides the keyboard
        return true
    }
}
