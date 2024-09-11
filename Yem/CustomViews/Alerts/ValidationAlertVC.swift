//
//  ValidationAlertView.swift
//  Yem
//
//  Created by Adam Zapiór on 25/01/2024.
//

import UIKit

//final class ValidationAlertVC: UIViewController {
//    private let containerView = UIView()
//    private let instructionTextView = UITextView()
//
//    private let titleLabel = TextLabel(
//        fontStyle: .title3,
//        fontWeight: .semibold,
//        textColor: .ui.primaryText,
//        textAlignment: .center
//    )
//    private let errorLabel = TextLabel(
//        fontStyle: .body,
//        fontWeight: .regular,
//        textColor: .ui.primaryText,
//        textAlignment: .center
//    )
//    private let actionButton = ActionButton(
//        title: "OK",
//        backgroundColor: .ui.theme
//    )
//    
//    private var alertTitle: String?
//    private var message: String?
//    private var dismissCompletion: (() -> Void)?
//    
//    // MARK: Lifecycle
//    
//    init(title: String, message: String, dismissCompletion: (() -> Void)? = nil) {
//        super.init(nibName: nil, bundle: nil)
//        self.alertTitle = title
//        self.message = message
//        self.dismissCompletion = dismissCompletion
//    }
//    
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
//
//        setupContainerView()
//        setupTitleLabel()
//        setupErrorLabel()
//        setupActionButton()
//    }
//    
//    // MARK: UI Setup
//
//    private func setupContainerView() {
//        view.addSubview(containerView)
//        containerView.backgroundColor = .systemBackground
//        containerView.layer.cornerRadius = 20
//        containerView.layer.borderWidth = 1
//        containerView.layer.borderColor = UIColor.ui.secondaryText.cgColor
//        
//        containerView.snp.makeConstraints { make in
//            make.centerX.centerY.equalToSuperview()
//            make.leading.trailing.equalToSuperview().inset(24)
////            make.width.lessThanOrEqualTo(view.snp.width).multipliedBy(0.8) // Maksymalnie 4/5 szerokości ekranu
////            make.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.75) // Maksymalnie 3/4 wysokości ekranu
////            make.height.greaterThanOrEqualTo(200).priority(.medium) // Minimalna wysokość
//        }
//    }
//    
//    private func setupTitleLabel() {
//        containerView.addSubview(titleLabel)
//        titleLabel.text = alertTitle ?? "Something went wrong"
//        
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(24)
//            make.leading.equalTo(containerView.snp.leading).offset(12)
//            make.trailing.equalTo(containerView.snp.trailing).offset(-12)
//        }
//    }
//    
//    private func setupErrorLabel() {
//        containerView.addSubview(errorLabel)
//        errorLabel.text = message ?? "Unable to complete request"
//
//        errorLabel.snp.makeConstraints { make in
//            make.top.equalTo(titleLabel.snp.bottom).offset(18)
//            make.leading.equalTo(containerView.snp.leading).offset(12)
//            make.trailing.equalTo(containerView.snp.trailing).offset(-12)
//        }
//
//        errorLabel.adjustsFontForContentSizeCategory = true
//        errorLabel.adjustsFontSizeToFitWidth = true
//        errorLabel.minimumScaleFactor = 0.5
//        
////        containerView.addSubview(instructionTextView)
////        instructionTextView.text = message ?? "Unable to complete request"
////        instructionTextView.isEditable = false
////        instructionTextView.isSelectable = false
////        instructionTextView.font = UIFont.preferredFont(forTextStyle: .body)
////        instructionTextView.textAlignment = .center
////        instructionTextView.backgroundColor = .clear
////        instructionTextView.textColor = .ui.primaryText
////        instructionTextView.translatesAutoresizingMaskIntoConstraints = false
////        
////        instructionTextView.snp.makeConstraints { make in
////            make.top.equalTo(titleLabel.snp.bottom).offset(18)
////            make.leading.equalTo(containerView.snp.leading).offset(12)
////            make.trailing.equalTo(containerView.snp.trailing).offset(-12)
////            make.height.lessThanOrEqualTo(200)
//////                make.height.greaterThanOrEqualTo(20).priority(.medium)
////        }
//    }
//    
////    func textViewDidChange(_ textView: UITextView) {
////        let newSize = textView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
////        textView.frame.size = CGSize(width: newSize.width, height: newSize.height)
////    }
//    
//    private func setupActionButton() {
//        containerView.addSubview(actionButton)
//        actionButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
//        
//        actionButton.snp.makeConstraints { make in
//            make.top.equalTo(errorLabel.snp.bottom).offset(24)
//            make.bottom.equalTo(containerView.snp.bottom).offset(-24)
//            make.leading.equalTo(containerView.snp.leading).offset(24)
//            make.trailing.equalTo(containerView.snp.trailing).offset(-24)
//        }
//    }
//    
//    @objc private func dismissVC() {
//        dismiss(animated: true) { [weak self] in
//            self?.dismissCompletion?() // Wywołaj zamknięcie po zamknięciu VC
//        }
//    }
//}


//
//  ValidationAlertView.swift
//  Yem
//
//  Created by Adam Zapiór on 25/01/2024.
//

import UIKit
import SnapKit

final class ValidationAlertVC: UIViewController {
    private let containerView = UIView()
    private let errorsTextView = UITextView()

    private let titleLabel = TextLabel(
        fontStyle: .title3,
        fontWeight: .semibold,
        textColor: .ui.primaryText,
        textAlignment: .center
    )
    private let actionButton = ActionButton(
        title: "OK",
        backgroundColor: .ui.theme
    )
    
    private var alertTitle: String?
    private var message: String?
    private var dismissCompletion: (() -> Void)?
    
    // MARK: Lifecycle
    
    init(title: String, message: String, dismissCompletion: (() -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.dismissCompletion = dismissCompletion
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)

        setupContainerView()
        setupTitleLabel()
        setupErrorLabel()
        setupActionButton()
    }
    
    // MARK: UI Setup

    private func setupContainerView() {
        view.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.ui.secondaryText.cgColor
        
        containerView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.lessThanOrEqualTo(view.snp.height).multipliedBy(0.75)
            make.height.greaterThanOrEqualTo(200).priority(.medium)
        }
    }
    
    private func setupTitleLabel() {
        containerView.addSubview(titleLabel)
        titleLabel.text = alertTitle ?? "Something went wrong"
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalTo(containerView.snp.leading).offset(12)
            make.trailing.equalTo(containerView.snp.trailing).offset(-12)
        }
    }
    
    private func setupErrorLabel() {
        containerView.addSubview(errorsTextView)
        errorsTextView.text = message ?? "Unable to complete request"
        errorsTextView.isEditable = false
        errorsTextView.isSelectable = false
        errorsTextView.font = UIFont.preferredFont(forTextStyle: .body)
        errorsTextView.textAlignment = .center
        errorsTextView.backgroundColor = .clear
        errorsTextView.textColor = .ui.primaryText
        errorsTextView.translatesAutoresizingMaskIntoConstraints = false
        errorsTextView.isScrollEnabled = true
        errorsTextView.showsVerticalScrollIndicator = true

        errorsTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.leading.equalTo(containerView.snp.leading).offset(12)
            make.trailing.equalTo(containerView.snp.trailing).offset(-12)
            make.height.greaterThanOrEqualTo(200)
        }
    }
    
    private func setupActionButton() {
        containerView.addSubview(actionButton)
        actionButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(errorsTextView.snp.bottom).offset(24).priority(.high)
            make.bottom.equalTo(containerView.snp.bottom).offset(-24).priority(.required)
            make.leading.equalTo(containerView.snp.leading).offset(24)
            make.trailing.equalTo(containerView.snp.trailing).offset(-24)
        }
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true) { [weak self] in
            self?.dismissCompletion?() 
        }
    }
}
