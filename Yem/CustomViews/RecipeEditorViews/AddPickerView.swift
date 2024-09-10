//
//  PickerButtonWithIconCell.swift
//  Yem
//
//  Created by Adam Zapiór on 11/12/2023.
//

import Combine
import UIKit

final class AddPickerView: UIView {
    var textOnButton = UILabel()

    private let iconContainer = UIView()
    private var icon: IconImage!
    private var iconImage: String
    private let textStyle: UIFont.TextStyle

    /// Publisher store
    var tapPublisher: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    /// Publisher
    private let tapSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        /// default values
        self.iconImage = "plus"
        self.textStyle = .body

        super.init(frame: frame)
        self.icon = IconImage(systemImage: iconImage, color: .ui.theme, textStyle: textStyle, contentMode: .scaleAspectFit)
        setupTapGesture()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(
        backgroundColor: UIColor? = UIColor.ui.primaryContainer,
        iconImage: String,
        textOnButton: String
    ) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.iconImage = iconImage
        self.icon = IconImage(systemImage: iconImage, color: .ui.theme, textStyle: textStyle, contentMode: .center)
        self.textOnButton.text = textOnButton
        self.textOnButton.textColor = .ui.secondaryText

        configure()
    }

    // MARK: UI Setup

    func setPlaceholderColor(_ color: UIColor) {
        textOnButton.textColor = color
    }

    private func configure() {
        iconContainer.addSubview(icon)
        addSubview(iconContainer)
        addSubview(textOnButton)

        layer.cornerRadius = 20

        icon.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        icon.maximumContentSizeCategory = .accessibilityMedium

        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalTo(textOnButton.snp.centerY)
            make.width.height.equalTo(40) // Ustaw stały rozmiar kontenera
        }

        textOnButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.equalTo(iconContainer.snp.trailing).offset(22)
            make.trailing.equalToSuperview().offset(-9)
        }

        textOnButton.font = UIFont.preferredFont(forTextStyle: .body)
        textOnButton.adjustsFontForContentSizeCategory = true
        textOnButton.adjustsFontSizeToFitWidth = true
        textOnButton.minimumScaleFactor = 0.5
        textOnButton.lineBreakMode = .byClipping
    }

    // MARK: - Gesture Setup

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    @objc private func viewTapped() {
        defaultOnTapAnimation()
        tapSubject.send(())
    }
}
