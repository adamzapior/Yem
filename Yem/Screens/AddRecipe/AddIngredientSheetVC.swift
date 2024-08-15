//
//  AddIgredientSheetVC.swift
//  Yem
//
//  Created by Adam Zapiór on 16/12/2023.
//

import LifetimeTracker
import UIKit

final class AddIngredientSheetVC: UIViewController {
    // MARK: - Properties
    
    var coordinator: Coordinator
    var viewModel: IngredientViewModel
    
    // MARK: - View properties
    
    private let ingredientNameTextfield = TextfieldWithIcon(
        backgroundColor: .ui.secondaryContainer,
        iconImage: "info.square",
        placeholderText: "Enter your igredient name*",
        textColor: .ui.secondaryText
    )
    private let countTextfield = TextfieldWithIcon(
        backgroundColor: .ui.secondaryContainer,
        iconImage: "bag.badge.plus",
        placeholderText: "Enter value*",
        textColor: .ui.secondaryText
    )
    private let valueTypeCell = AddPicker(
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
    
    let value: CGFloat = 0
    
    // MARK: - Lifecycle
    
    init(viewModel: IngredientViewModel, coordinator: Coordinator) {
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
        viewModel.delegateIngredientSheet = self
        
        setupUI()
        setupTag()
        setupDelegate()
        setupDataSource()
        
        let contentHeight = calculateContentHeight()
        let customDetentId = UISheetPresentationController.Detent.Identifier("customDetent")
        let contentDetent = UISheetPresentationController.Detent.custom(identifier: customDetentId) { _ in
            contentHeight
        }
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [contentDetent]
            presentationController.prefersGrabberVisible = true
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
        stackView.addArrangedSubview(countTextfield)
        stackView.addArrangedSubview(valueTypeCell)
        
        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        buttonsStackView.addArrangedSubview(addButton)
        buttonsStackView.addArrangedSubview(cancelButton)
    }
    
    private func calculateContentHeight() -> CGFloat {
        let marginsAndSpacings: CGFloat = 124
        let width = UIScreen.main.bounds.width - 24
        let size = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)

        let elementHeights: CGFloat = [
            ingredientNameTextfield.systemLayoutSizeFitting(size).height,
            countTextfield.systemLayoutSizeFitting(size).height,
            valueTypeCell.systemLayoutSizeFitting(size).height,
            addButton.systemLayoutSizeFitting(size).height,
            cancelButton.systemLayoutSizeFitting(size).height
        ].reduce(0, +)

        return elementHeights + marginsAndSpacings
    }
}

// MARK: - Delegate & data source items

extension AddIngredientSheetVC {}

// MARK: Gestures: TextfieldWithIconCellDelegate & PickerButtonWithIconCellDelegate

extension AddIngredientSheetVC: TextfieldWithIconDelegate, AddPickerDelegate, ActionButtonDelegate {
    func setupDelegate() {
        /// textfields:
        ingredientNameTextfield.delegate = self
        countTextfield.delegate = self
        
        /// picker:
        valueTypeCell.delegate = self
        
        /// mainButton:
        addButton.delegate = self
        cancelButton.delegate = self
        
        valueTypePickerView.delegate = self
    }
    
    func setupTag() {
        /// textfields:
        ingredientNameTextfield.tag = 1
        countTextfield.tag = 2
        
        /// mainButton:
        addButton.tag = 1
        cancelButton.tag = 2
    }
    
    func setupDataSource() {
        valueTypePickerView.dataSource = self
    }
    
    /// Update ViewModel
    func updateTextfieldsInViewModel(for textfield: TextfieldWithIcon) {
        switch textfield.tag {
        case 1:
            if let text = textfield.textField.text {
                viewModel.ingredientName = text
            }
        case 2:
            if let text = textfield.textField.text {
                let filteredText = text.filter { "0123456789".contains($0) }
                textfield.textField.text = filteredText
                viewModel.ingredientValue = filteredText
            }
        default: break
        }
    }
    
    func textFieldDidChange(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        updateTextfieldsInViewModel(for: textfield)
    }
    
    func textFieldDidBeginEditing(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        updateTextfieldsInViewModel(for: textfield)
    }
    
    func textFieldDidEndEditing(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        updateTextfieldsInViewModel(for: textfield)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // turn off keyboard
        return true
    }
    
    private func configureKeyboardType() {
        countTextfield.keyboardType = .decimalPad
    }
    
    // Picker
    func pickerTapped(item: AddPicker) {
        popUpPicker(for: valueTypePickerView, title: "Select ingredient value type")
    }
    
    // Add & Cancel buttons
    func actionButtonTapped(_ cell: ActionButton) {
        switch cell.tag {
        case 1:
            /// add button
            cell.defaultOnTapAnimation()
            
            let success = viewModel.addIngredientToList()
            if success {
                coordinator.dismissSheet()
            }
        case 2:
            cell.defaultOnTapAnimation()
            coordinator.dismissSheet()
        default: break
        }
    }
    
    // for view
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: -  PickerView setup

extension AddIngredientSheetVC: UIPickerViewDelegate, UIPickerViewDataSource {
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
        label.text = viewModel.ingredientValueTypeArray[row].displayName
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedRow = viewModel.ingredientValueTypeArray[row]
        valueTypeCell.textOnButton.text = selectedRow.displayName
        valueTypeCell.textOnButton.textColor = .ui.primaryText
        viewModel.ingredientValueType = selectedRow.displayName
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
 
            let selectedValueType = self.viewModel.ingredientValueTypeArray[selectedRow]
            self.valueTypeCell.textOnButton.text = selectedValueType.displayName
            self.valueTypeCell.textOnButton.textColor = .ui.primaryText
            self.viewModel.ingredientValueType = selectedValueType.displayName
        })
        
        selectAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(selectAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Ingredient delegate from ViewModel

extension AddIngredientSheetVC: AddIngredientSheetVCDelegate {
    func delegateIngredientSheetError(_ type: ValidationErrorTypes) {
        switch type {
        case .recipeTitle:
            break
        case .difficulty:
            break
        case .servings:
            break
        case .prepTime:
            break
        case .spicy:
            break
        case .category:
            break
        case .ingredientName:
            ingredientNameTextfield.setPlaceholderColor(.ui.placeholderError)
        case .ingredientValue:
            countTextfield.setPlaceholderColor(.ui.placeholderError)
        case .ingredientValueType:
            valueTypeCell.setPlaceholderColor(.ui.placeholderError)
        case .ingredientList:
            break
        case .instruction:
            break
        case .instructionList:
            break
        }
    }
}

#if DEBUG
extension AddIngredientSheetVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
