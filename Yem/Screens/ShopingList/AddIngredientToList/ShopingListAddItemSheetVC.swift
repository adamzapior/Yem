//
//  AddIngredientToListSheetVC.swift
//  Yem
//
//  Created by Adam Zapiór on 25/08/2024.
//

import Combine
import CombineCocoa
import LifetimeTracker
import UIKit

final class ShopingListAddItemSheetVC: UIViewController {
    private let coordinator: ShopingListCoordinator
    private let viewModel: ShopingListAddItemSheetVM
        
    private let ingredientNameTextfield = TextfieldWithIcon(
        backgroundColor: .ui.secondaryContainer,
        iconImage: "info.square",
        placeholderText: "Enter your igredient name*",
        textColor: .ui.secondaryText
    )
    private let ingredientValueTextfield = TextfieldWithIcon(
        backgroundColor: .ui.secondaryContainer,
        iconImage: "bag.badge.plus",
        placeholderText: "Enter ingredient value*",
        textColor: .ui.secondaryText,
        keyboardType: .decimalPad
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
    
    init(viewModel: ShopingListAddItemSheetVM, coordinator: ShopingListCoordinator) {
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
        setupPickerDelegate()
        setupPickerDataSource()
        
        setupVoiceOverAccessibility()
        
        observeViewModelEventOutput()
        observeTextFields()
        observeActionButtons()
        observeValueTypePicker()
        
        hideKeyboardWhenTappedAround()
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
    
    private func setupVoiceOverAccessibility() {
        ingredientNameTextfield.isAccessibilityElement = true
        ingredientNameTextfield.accessibilityLabel = "Ingredient name"
        ingredientNameTextfield.accessibilityHint = "Enter your ingredient name"

        ingredientValueTextfield.isAccessibilityElement = true
        ingredientValueTextfield.accessibilityLabel = "Ingredient value"
        ingredientValueTextfield.accessibilityHint = "Enter ingredient value"
        
        ingredientValueTypePicker.isAccessibilityElement = true
        ingredientValueTypePicker.accessibilityLabel = "Ingredient value type"
        ingredientValueTypePicker.accessibilityHint = "Select ingredient value type"
        
        addButton.isAccessibilityElement = true
        addButton.accessibilityLabel = "Add buton"
        addButton.accessibilityHint = "This button will add your item to list"
        
        cancelButton.isAccessibilityElement = true
        cancelButton.accessibilityLabel = "Cancel button"
        cancelButton.accessibilityHint = "This button will dismiss this view, where you can add ingredient to list"
    }
}

// MARK: - Observed Output & UI Views

extension ShopingListAddItemSheetVC {
    private func observeViewModelEventOutput() {
        viewModel.outputPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                self.handleViewModelOutput(event: event)
            }
            .store(in: &cancellables)
    }
    
    private func observeTextFields() {
        ingredientNameTextfield.textField
            .textPublisher
            .sink { [unowned self] text in
                self.viewModel.inputEvent.send(
                    .valueChanged(for: .ingredientName(value: text ?? "")
                    )
                )
            }
            .store(in: &cancellables)

        ingredientValueTextfield.textField
            .textPublisher
            .sink { [unowned self] text in
                self.viewModel.inputEvent.send(
                    .valueChanged(for: .ingredientValue(value: text ?? "")
                    )
                )
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

// MARK: - Handle Output & UI Views

extension ShopingListAddItemSheetVC {
    private func handleViewModelOutput(event: ShopingListAddItemSheetVM.Output) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            switch event {
            case .updateField(let type):
                switch type {
                case .ingredientName(value: let value):
                    ingredientNameTextfield.textField.text = value
                    handleUpdateAccessibility(for: .ingredientNameTextField, value: value)
                case .ingredientValue(value: let value):
                    ingredientValueTextfield.textField.text = value
                    handleUpdateAccessibility(for: .ingredientNameTextField, value: value)
                case .ingredientValueType(value: let value):
                    let value = value.name
                    ingredientValueTypePicker.textOnButton.text = value
                    handleUpdateAccessibility(for: .ingredientNameTextField, value: value)
                    ingredientValueTypePicker.textOnButton.textColor = .ui.primaryText
                }
            case .validationError(let type):
                handleValidationError(type)
            }
        }
    }
    
    private func handleUpdateAccessibility(
        for element: ShopingListAddItemSheetVM.AccessibilityElement,
        value: String
    ) {
        switch element {
        case .ingredientNameTextField:
            ingredientNameTextfield.accessibilityValue = value
            ingredientNameTextfield.accessibilityHint = value.isEmpty ? "Enter your ingredient name" : nil
        case .ingredientValueTextField:
            ingredientValueTextfield.accessibilityValue = value
            ingredientValueTextfield.accessibilityHint = value.isEmpty ? "Enter ingredient value" : nil
        case .ingredientValueTypePicker:
            ingredientValueTypePicker.accessibilityValue = value
            ingredientValueTypePicker.accessibilityHint = value.isEmpty ? "Select ingredient value type" : nil
        }
    }
    
    private func handleActionButtonEvent(type: ActionButtonType) {
        switch type {
        case .add:
            do {
                try viewModel.addIngredientToShoppingList()
                dismissSheet()
            } catch let error as ShopingListAddItemSheetVM.ValidationErrors {
                for validationError in error.errors {
                    switch validationError {
                    case .invalidName:
                        handleValidationError(.invalidName)
                    case .invalidValue:
                        handleValidationError(.invalidValue)
                    case .invalidValueType:
                        handleValidationError(.invalidValueType)
                    }
                }
            } catch {
                print("DEBUG: Unexpected error when handling button event in ShopingListAddItemSheetVC: \(error)")
            }

        case .cancel:
            dismissSheet() 
        }
    }
    
    private func handleValidationError(_ type: ShopingListAddItemSheetVM.ValidationError) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch type {
            case .invalidName:
                ingredientNameTextfield.setPlaceholderColor(.ui.placeholderError)
            case .invalidValue:
                ingredientValueTextfield.setPlaceholderColor(.ui.placeholderError)
            case .invalidValueType:
                ingredientValueTypePicker.setPlaceholderColor(.ui.placeholderError)
            }
        }
    }
}

// MARK: -  UIPickerView Delegate

extension ShopingListAddItemSheetVC: UIPickerViewDelegate {
    private func setupPickerDelegate() {
        valueTypePickerView.delegate = self
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
        let selectedRow = viewModel.ingredientValueTypeArray[row]
        viewModel.inputEvent.send(.valueChanged(for: .ingredientValueType(value: selectedRow)))
    }
}

// MARK: - UIPickerViewDataSource

extension ShopingListAddItemSheetVC: UIPickerViewDataSource {
    func setupPickerDataSource() {
        valueTypePickerView.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.ingredientValueTypeArray.count
    }
}

// MARK: - UIPickerView: helper methods

extension ShopingListAddItemSheetVC {
    func popUpPicker(for pickerView: UIPickerView, title: String) {
        view.endEditing(true)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.tag = pickerView.tag
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: view.frame.width - 20, height: 180.VAdapted)
        pickerView.frame = CGRect(x: 0, y: 0, width: vc.preferredContentSize.width, height: 180.VAdapted)
        vc.view.addSubview(pickerView)
        
        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.setValue(vc, forKey: "contentViewController")
        
        let selectAction = UIAlertAction(title: "Select", style: .default, handler: { _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            
            let selectedValueType = self.viewModel.ingredientValueTypeArray[selectedRow]
            self.viewModel.inputEvent.send(.valueChanged(for: .ingredientValueType(value: selectedValueType)))
        })
        
        selectAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(selectAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Navigation

extension ShopingListAddItemSheetVC {
    private func dismissSheet() {
        coordinator.dismissSheet()
    }
}

// MARK: - Helper enum (Button action type)

extension ShopingListAddItemSheetVC {
    private enum ActionButtonType {
        case add
        case cancel
    }
}


// MARK: - LifetimeTracker

#if DEBUG
extension ShopingListAddItemSheetVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
