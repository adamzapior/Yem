//
//  AddIgredientSheetVC.swift
//  Yem
//
//  Created by Adam Zapiór on 16/12/2023.
//

import Combine
import LifetimeTracker
import UIKit

final class ManageRecipeIngredientFormVC: UIViewController {
    private weak var coordinator: ManageRecipeCoordinator?
    private var viewModel: ManageRecipeVM
    
    private let ingredientNameTextfield = TextfieldWithIcon(
        backgroundColor: .ui.secondaryContainer,
        iconImage: "info.square",
        placeholderText: "Enter your igredient name*",
        textColor: .ui.secondaryText
    )
    private let ingredientValueTextfield = TextfieldWithIcon(
        backgroundColor: .ui.secondaryContainer,
        iconImage: "bag.badge.plus",
        placeholderText: "Enter value*",
        textColor: .ui.secondaryText
    )
    private let ingredientValueTypePicker = AddPickerView(
        backgroundColor: .ui.secondaryContainer,
        iconImage: "note.text.badge.plus",
        textOnButton: "Select value type*"
    )
    private let addButton = ActionButton(
        title: "Add",
        backgroundColor: .ui.addBackground
    )
    private let cancelButton = ActionButton(
        title: "Cancel",
        backgroundColor: .ui.cancelBackground
    )
    
    private let valueTypePickerView = UIPickerView()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private let buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    private let screenWidth = UIScreen.main.bounds.width - 10
    private let screenHeight = UIScreen.main.bounds.height / 2
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    
    init(viewModel: ManageRecipeVM, coordinator: ManageRecipeCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
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
        setupPicker()
        configureKeyboardType()
        setupVoiceOverAccessibility()
        hideKeyboardWhenTappedAround()
        
        observeViewModelEventOutput()
        observeTextFields()
        observeValueTypePicker()
        observeActionButtons()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        view.addSubview(buttonsStackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        stackView.addArrangedSubview(ingredientNameTextfield)
        stackView.addArrangedSubview(ingredientValueTextfield)
        stackView.addArrangedSubview(ingredientValueTypePicker)
        
        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        buttonsStackView.addArrangedSubview(addButton)
        buttonsStackView.addArrangedSubview(cancelButton)
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
        let marginsAndSpacings: CGFloat = 124
        let bottomMargin: CGFloat = 16
        let width = UIScreen.main.bounds.width - 24
        let size = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        
        let elementHeights: CGFloat = [
            ingredientNameTextfield.systemLayoutSizeFitting(size).height,
            ingredientValueTextfield.systemLayoutSizeFitting(size).height,
            ingredientValueTypePicker.systemLayoutSizeFitting(size).height,
            addButton.systemLayoutSizeFitting(size).height,
            cancelButton.systemLayoutSizeFitting(size).height
        ].reduce(0, +)
        
        return elementHeights + marginsAndSpacings + bottomMargin
    }
    
    private func configureKeyboardType() {
        ingredientNameTextfield.keyboardType = .default /// for readability :)
        ingredientValueTextfield.keyboardType = .decimalPad
    }
    
    private func setupPicker() {
        valueTypePickerView.delegate = self
        valueTypePickerView.dataSource = self
    }
    
    func setupVoiceOverAccessibility() {
        ingredientNameTextfield.isAccessibilityElement = true
        ingredientNameTextfield.accessibilityLabel = "Ingredient name"
        ingredientNameTextfield.accessibilityHint = "Enter your ingredient name"
        
        ingredientValueTextfield.isAccessibilityElement = true
        ingredientValueTextfield.accessibilityLabel = "Ingredient value"
        ingredientValueTextfield.accessibilityHint = "Enter ingredient value"
        
        ingredientValueTypePicker.isAccessibilityElement = true
        ingredientValueTypePicker.accessibilityLabel = "Ingredient value type"
        ingredientValueTypePicker.accessibilityHint = "Select ingredient value type"
    }
}

// MARK: - Observe ViewModel Output & UI actions

extension ManageRecipeIngredientFormVC {
    private func observeViewModelEventOutput() {
        viewModel.outputIngredientFormEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                self.handleViewModelOutput(for: event)
            }
            .store(in: &cancellables)
    }
    
    private func observeTextFields() {
        ingredientNameTextfield.textField
            .textPublisher
            .sink { [unowned self] text in
                self.viewModel.inputIngredientFormEvent.send(.sendIngredientValues(.ingredientName(text ?? "")))
            }
            .store(in: &cancellables)
            
        ingredientValueTextfield.textField
            .textPublisher
            .sink { [unowned self] text in
                self.viewModel.inputIngredientFormEvent.send(.sendIngredientValues(.ingredientValue(text ?? "")))
            }
            .store(in: &cancellables)
    }
        
    private func observeValueTypePicker() {
        ingredientValueTypePicker
            .tapPublisher
            .sink { [unowned self] _ in
                self.popUpPicker(for: valueTypePickerView, title: "Select ingredient value type")
            }
            .store(in: &cancellables)
    }
        
    // Action buttons
    private func observeActionButtons() {
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

extension ManageRecipeIngredientFormVC {
    private func handleViewModelOutput(for event: ManageRecipeVM.IngredientFormOutput) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch event {
            case .updateIngredientForm(let form):
                handleIngredientFormValues(for: form)
                handleUpdateAccessibility(for: form)
            case .validationError(let type):
                handleValidationError(for: type)
            }
        }
    }
    
    private func handleIngredientFormValues(for form: ManageRecipeVM.IngredientForm) {
            switch form {
            case .ingredientName(let value):
                ingredientNameTextfield.textField.text = value
            case .ingredientValue(let value):
                ingredientValueTextfield.textField.text = value
            case .ingredientValueType(let value):
                ingredientValueTypePicker.textOnButton.text = value
                ingredientValueTypePicker.textOnButton.textColor = .ui.primaryText
            }
    }
    
    private func handleValidationError(for errorType: ManageRecipeVM.ErrorType.Ingredients) {
        switch errorType {
        case .ingredientName:
            ingredientNameTextfield.setPlaceholderColor(.ui.placeholderError)
        case .ingredientValue:
            ingredientValueTextfield.setPlaceholderColor(.ui.placeholderError)
        case .ingredientValueType:
            ingredientValueTypePicker.setPlaceholderColor(.ui.placeholderError)
        case .ingredientsList:
            break
        }
    }
    
    private func handleUpdateAccessibility(for element: ManageRecipeVM.IngredientForm) {
        switch element {
        case .ingredientName(let value):
            ingredientNameTextfield.accessibilityValue = value
            ingredientNameTextfield.accessibilityHint = value.isEmpty ? "Enter your ingredient name" : nil
        case .ingredientValue(let value):
            ingredientValueTextfield.accessibilityValue = value
            ingredientValueTextfield.accessibilityHint = value.isEmpty ? "Enter ingredient value" : nil
        case .ingredientValueType(let value):
            ingredientValueTypePicker.accessibilityValue = value
            ingredientValueTypePicker.accessibilityHint = value.isEmpty ? "Select ingredient value type" : nil
        }
    }
        
    private func handleActionButtonEvent(type: ActionButtonType) {
        switch type {
        case .add:
            do {
                try viewModel.addIngredientToList()
                dismissSheet()
            } catch (let error) {
                print("DEBUG: \(error)")
            }
        case .cancel:
            dismissSheet()
        }
    }
}

// MARK: -  PickerView setup

extension ManageRecipeIngredientFormVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.ingredientValueTypeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let reuseLabel = view as? UILabel {
            label = reuseLabel
        } else {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
            label.textAlignment = .center
        }
        label.text = viewModel.ingredientValueTypeArray[row].name
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedRow = viewModel.ingredientValueTypeArray[row].name
        viewModel.inputIngredientFormEvent.send(.sendIngredientValues(.ingredientValueType(selectedRow)))
    }
    
    func popUpPicker(for pickerView: UIPickerView, title: String) {
        view.endEditing(true)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.tag = pickerView.tag
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: view.frame.width - 20, height: 180)
        pickerView.frame = CGRect(x: 0, y: 0, width: vc.preferredContentSize.width, height: 180)
        vc.view.addSubview(pickerView)
        
        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.setValue(vc, forKey: "contentViewController")
        
        let selectAction = UIAlertAction(title: "Select", style: .default, handler: { _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
 
            let selectedValueType = self.viewModel.ingredientValueTypeArray[selectedRow].name
            self.viewModel.inputIngredientFormEvent.send(.sendIngredientValues(.ingredientValueType(selectedValueType)))
        })
        
        selectAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(selectAction)
        present(alert, animated: true, completion: nil)
    }
    
    func pickerTapped(item: AddPickerView) {
        popUpPicker(for: valueTypePickerView, title: "Select ingredient value type")
    }
}

// MARK: - Navigation

extension ManageRecipeIngredientFormVC {
    private func dismissSheet() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.dismissSheet()
        }
    }
}

// MARK: - Helper enum

extension ManageRecipeIngredientFormVC {
    private enum ActionButtonType {
        case add
        case cancel
    }
}

// MARK: - LifetimeTracker


#if DEBUG
extension ManageRecipeIngredientFormVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
