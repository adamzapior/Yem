//
//  DualOptionAlertVC.swift
//  Yem
//
//  Created by Adam Zapiór on 18/03/2024.
//

import UIKit

final class DualOptionAlertVC: UIViewController {
    private let containerView = UIView()

    private let titleLabel = ReusableTextLabel(fontStyle: .title3, fontWeight: .semibold, textColor: .ui.primaryText, textAlignment: .center)
    private let errorLabel = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.primaryText, textAlignment: .center)
    private let okButton = MainActionButton(title: "OK", backgroundColor: .ui.theme)
    private let cancelButton = MainActionButton(title: "Cancel", backgroundColor: .ui.cancelBackground ?? .red)

    private var alertTitle: String?
    private var message: String?
    private var okAction: (() -> Void)?
    private var cancelAction: (() -> Void)?

    init(title: String, message: String, okAction: (() -> Void)? = nil, cancelAction: (() -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.okAction = okAction
        self.cancelAction = cancelAction
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
        setupButtons()
    }

    private func setupContainerView() {
        view.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.ui.secondaryText?.cgColor

        containerView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.greaterThanOrEqualTo(200)
            make.leading.trailing.equalToSuperview().inset(24)
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
        containerView.addSubview(errorLabel)
        errorLabel.text = message ?? "Unable to complete request"

        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.leading.equalTo(containerView.snp.leading).offset(12)
            make.trailing.equalTo(containerView.snp.trailing).offset(-12)
        }
    }

    private func setupButtons() {
        containerView.addSubview(okButton)
        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)

        containerView.addSubview(cancelButton)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)

        okButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(24)
            make.leading.equalTo(containerView.snp.leading).offset(24)
            make.trailing.equalTo(containerView.snp.centerX).offset(-12)
            make.bottom.equalTo(containerView.snp.bottom).offset(-24)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(errorLabel.snp.bottom).offset(24)
            make.leading.equalTo(containerView.snp.centerX).offset(12)
            make.trailing.equalTo(containerView.snp.trailing).offset(-24)
            make.bottom.equalTo(containerView.snp.bottom).offset(-24)
        }
    }

    @objc func okButtonTapped() {
        okAction?()
        dismiss(animated: true)
    }

    @objc func cancelButtonTapped() {
        cancelAction?()
        dismiss(animated: true)
    }
}
