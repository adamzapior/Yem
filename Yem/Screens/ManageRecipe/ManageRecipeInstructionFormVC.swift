//
//  AddInstructionSheetVC.swift
//  Yem
//
//  Created by Adam Zapiór on 21/01/2024.
//

import Combine
import CombineCocoa
import LifetimeTracker
import UIKit

final class ManageRecipeInstructionFormVC: UIViewController {
    private weak var coordinator: ManageRecipeCoordinator?
    private let viewModel: ManageRecipeVM
    
    private var textFieldContentView: UIView = {
        let content = UIView()
        content.layer.cornerRadius = 20
        content.backgroundColor = .ui.secondaryContainer
        return content
    }()
    
//    private let instructionTextfield = TextfieldWithIcon(
//        iconImage: "note",
//        placeholderText: "Add new instruction...",
//        textColor: .ui.secondaryText
//    )
    
    private var icon: IconImage!
    private var iconImage: String
    private var titleLabel = TextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.primaryText)
    private var nameOfRowText: String
    private var textStyle: UIFont.TextStyle
    private var placeholder = TextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.secondaryText)
    
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
    
    private let addButton = ActionButton(title: "Add", backgroundColor: .ui.addBackground)
    private let cancelButton = ActionButton(title: "Cancel", backgroundColor: .ui.cancelBackground)
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
        return stack
    }()
    
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Lifecycle
    
    init(viewModel: ManageRecipeVM, coordinator: ManageRecipeCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.iconImage = "note"
        self.textStyle = .body
        self.nameOfRowText = "Add new instruction"
        self.icon = IconImage(systemImage: iconImage, color: .ui.theme, textStyle: textStyle)
        super.init(nibName: nil, bundle: nil)
        
#if DEBUG
        trackLifetime()
#endif
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSheet()
        setupVoiceOverAccessibility()
        hideKeyboardWhenTappedAround()
        
        observeViewModelEventOutput()
        observeTextFields()
        observeButtons()
    }
        
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(addButton)
        view.addSubview(cancelButton)
        
        view.addSubview(textFieldContentView)
        textFieldContentView.addSubview(icon)
        textFieldContentView.addSubview(titleLabel)
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
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerY.equalTo(icon)
            make.leading.equalTo(icon.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-18)
        }
        
        titleLabel.text = "Instruction"
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
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
    
    private func setupSheet() {
        let contentHeight = calculateContentHeight()
        let customDetentId = UISheetPresentationController.Detent.Identifier("customDetent")
        let contentDetent = UISheetPresentationController.Detent.custom(identifier: customDetentId) { _ in
            contentHeight
        }
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [contentDetent]
            presentationController.prefersGrabberVisible = true
        }
    }
    
    private func calculateContentHeight() -> CGFloat {
        let marginsAndSpacings: CGFloat = 36
        let width = UIScreen.main.bounds.width - 24
        let size = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)

        let elementHeights: CGFloat = [
            textFieldContentView.systemLayoutSizeFitting(size).height,
            addButton.systemLayoutSizeFitting(size).height,
            cancelButton.systemLayoutSizeFitting(size).height
        ].reduce(0, +)
 
        return elementHeights + marginsAndSpacings
    }
    
    private func setupVoiceOverAccessibility() {
        textField.isAccessibilityElement = true
        textField.accessibilityLabel = "New instruction textfield"
        textField.accessibilityHint = "Enter your instruction"
        
        addButton.isAccessibilityElement = true
        addButton.accessibilityLabel = "Add button"
        addButton.accessibilityHint = "Add instruction to your instructions list"

        cancelButton.isAccessibilityElement = true
        cancelButton.accessibilityLabel = "Cancel button"
        cancelButton.accessibilityHint = "Dismiss add instruction view"
    }
}

// MARK: - Observe ViewModel Output & UI actions

extension ManageRecipeInstructionFormVC {
    private func observeViewModelEventOutput() {
        viewModel.outputInstructionFormPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                self.handleViewModelOutput(for: event)
            }
            .store(in: &cancellables)
    }
    
    private func observeTextFields() {
        textField
            .textPublisher
            .sink { [unowned self] text in
                self.viewModel.inputInstructionFormEvent.send(.sendInstructionValue(text ?? ""))
            }
            .store(in: &cancellables)
    }
    
    private func observeButtons() {
        addButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.handleActionButtonEvent(type: .add)
            }
            .store(in: &cancellables)
            
        cancelButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.handleActionButtonEvent(type: .cancel)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Handle Output & UI Actions

extension ManageRecipeInstructionFormVC {
    private func handleViewModelOutput(for event: ManageRecipeVM.InstructionFormOutput) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch event {
            case .updateInstructionValue(let value):
                handleInstructionString(value)
            case .validationError(let type):
                handleValidationError(type)
            }
        }
    }
    
    private func handleInstructionString(_ value: String) {
        textField.text = value
            
        let isStringEmpty = value.isEmpty
        switch isStringEmpty {
        case true:
            placeholder.animateFadeIn()
        case false:
            placeholder.animateFadeOut()
        }
    }
    
    private func handleValidationError(_ type: ManageRecipeVM.ErrorType.Instructions) {
        if type == .instruction {
            placeholder.textColor = .ui.placeholderError
        }
    }

    private func handleActionButtonEvent(type: ActionButtonType) {
        switch type {
        case .add:
            do {
                try viewModel.addInstructionToList()
                dismissSheet()
            } catch (let error) {
                print("DEBUG: \(error)")
            }
        case .cancel:
            dismissSheet()
        }
    }
}

// MARK: - Navigation

extension ManageRecipeInstructionFormVC {
    private func dismissSheet() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.dismissSheet()
        }
    }
}

// MARK: - Helper enum

extension ManageRecipeInstructionFormVC {
    private enum ActionButtonType {
        case add
        case cancel
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension ManageRecipeInstructionFormVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
