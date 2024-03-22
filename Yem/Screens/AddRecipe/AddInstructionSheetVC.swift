//
//  AddInstructionSheetVC.swift
//  Yem
//
//  Created by Adam Zapiór on 21/01/2024.
//

import UIKit

final class AddInstructionSheetVC: UIViewController {
    // MARK: - Properties
    
    var coordinator: AddRecipeCoordinator
    var viewModel: AddRecipeViewModel
    
    // MARK: - View properties
    
    private var textFieldContentView: UIView = {
        let content = UIView()
        content.layer.cornerRadius = 20
        content.backgroundColor = .ui.secondaryContainer
        return content
    }()
    
    private var icon: IconImage!
    private var iconImage: String
    private var nameOfRow = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.primaryText)
    private var nameOfRowText: String
    private var textStyle: UIFont.TextStyle
    private var placeholder = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.secondaryText)
    
    private lazy var textField: UITextView = {
        let text = UITextView()
        text.backgroundColor = .ui.secondaryContainer
        text.keyboardType = keyboardType
        return text
    }()
    
    private var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }
    
    private let addButton = MainActionButton(title: "Add", backgroundColor: .ui.addBackground!)
    private let cancelButton = MainActionButton(title: "Cancel", backgroundColor: .ui.cancelBackground ?? .ui.theme)
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
        return stack
    }()
    
    // MARK: - Lifecycle
    
    init(viewModel: AddRecipeViewModel, coordinator: AddRecipeCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.iconImage = "note"
        self.textStyle = .body
        self.nameOfRowText = "Add new instruction"
        self.icon = IconImage(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegateInstructionSheet = self

        let smallDetentId = UISheetPresentationController.Detent.Identifier("small")
        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallDetentId) { _ in
            430
        }
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [smallDetent, smallDetent]
            presentationController.prefersGrabberVisible = true
        }
        
        configureTags()
        configureDelegate()
        setupUI()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func configureTags() {
        addButton.tag = 1
        cancelButton.tag = 2
    }
    
    private func configureDelegate() {
        textField.delegate = self
        addButton.delegate = self
        cancelButton.delegate = self
    }
        
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(addButton)
        view.addSubview(cancelButton)
        
        view.addSubview(textFieldContentView)
        textFieldContentView.addSubview(icon)
        textFieldContentView.addSubview(nameOfRow)
        textFieldContentView.addSubview(textField)
        textFieldContentView.addSubview(placeholder)
        
        textFieldContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.greaterThanOrEqualTo(240.VAdapted)
        }
        
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
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(textFieldContentView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
    }
}

// MARK: - ViewModel & Button delegate:

extension AddInstructionSheetVC: AddInstructionSheetVCDelegate {
    func delegateInstructionError(_ type: ValidationErrorTypes) {
        if type == .instruction {
//            noteRow.placeholder.textColor = .ui.placeholderError
        }
    }
}

extension AddInstructionSheetVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let text = textView.text {
            viewModel.instruction = text
        }
        
        if viewModel.instruction.isEmpty {
            placeholder.textColor = .clear
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            viewModel.instruction = text
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if viewModel.instruction.isEmpty {
            placeholder.textColor = .ui.secondaryText
        }
    }
}

extension AddInstructionSheetVC: MainActionButtonDelegate {
    func mainActionButtonTapped(_ button: MainActionButton) {
        switch button.tag {
        case 1:
            button.onTapAnimation()
            
            let success = viewModel.addInstructionToList()
            if success {
                coordinator.dismissVC()
            } else {}
        case 2:
            button.onTapAnimation()
            coordinator.dismissVC()
        default: break
        }
    }
    
    // for view
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
