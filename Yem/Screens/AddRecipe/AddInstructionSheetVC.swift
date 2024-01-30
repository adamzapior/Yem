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
    
    private var icon: IconImage!
    private var iconImage: String
    private var nameOfRow = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.primaryText)
    private var nameOfRowText: String
    private var textStyle: UIFont.TextStyle
    var placeholder = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.secondaryText)
    
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
    
    private let noteRow = NoteWithIconRow(nameOfRowText: "Add new instruction", iconImage: "note", placeholderText: "Enter new step", textColor: .ui.primaryText)
    
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
            380
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
        noteRow.delegate = self
        addButton.delegate = self
        cancelButton.delegate = self
    }
        
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(noteRow)
        view.addSubview(addButton)
        view.addSubview(cancelButton)
        
        noteRow.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.greaterThanOrEqualTo(150)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(noteRow.snp.bottom).offset(12)
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
            noteRow.placeholder.textColor = .ui.placeholderError
        }
    }
}

extension AddInstructionSheetVC: NoteWithIconRowDelegate {
    func textFieldDidBeginEditing(_ textfield: NoteWithIconRow, didUpdateText text: String) {
        if let text = textfield.textField.text {
            viewModel.instruction = text
        }
    }
    
    func textFieldDidChange(_ textfield: NoteWithIconRow, didUpdateText text: String) {
        if let text = textfield.textField.text {
            viewModel.instruction = text
        }
    }
    
    func textFieldDidEndEditing(_ textfield: NoteWithIconRow, didUpdateText text: String) {
        if let text = textfield.textField.text {
            viewModel.instruction = text
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
