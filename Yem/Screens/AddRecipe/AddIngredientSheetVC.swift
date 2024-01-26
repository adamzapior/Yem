//
//  AddIgredientSheetVC.swift
//  Yem
//
//  Created by Adam Zapiór on 16/12/2023.
//

import UIKit

class AddIngredientSheetVC: UIViewController {
    // MARK: - Properties
    
    var coordinator: AddRecipeCoordinator
    var viewModel: AddRecipeViewModel
    
    // MARK: - View properties
    
    private let ingredientNameTextfield = TextfieldWithIconRow(backgroundColor: .ui.secondaryContainer, iconImage: "info.square", placeholderText: "Enter your igredient name", textColor: .ui.secondaryText)
    private let countTextfield = TextfieldWithIconRow(backgroundColor: .ui.secondaryContainer, iconImage: "bag.badge.plus", placeholderText: "Enter value", textColor: .ui.secondaryText)
    private let valueTypeCell = PickerWithIconRow(backgroundColor: .ui.secondaryContainer, iconImage: "note.text.badge.plus", textOnButton: "Select value type")
    private let addButton = MainActionButton(title: "Add", backgroundColor: .ui.addBackground!)
    private let cancelButton = MainActionButton(title: "Cancel", backgroundColor: .ui.cancelBackground ?? .ui.theme)
    
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
    
    // MARK: - Lifecycle
    
    init(viewModel: AddRecipeViewModel, coordinator: AddRecipeCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let smallDetentId = UISheetPresentationController.Detent.Identifier("small")
        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallDetentId) { _ in
            300
        }
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [smallDetent, smallDetent]
            presentationController.prefersGrabberVisible = true
        }
        
        setupUI()
        configureComponents()
        
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
}

// MARK: - Delegate & data source items

extension AddIngredientSheetVC {
    private func configureComponents() {
        configureTags()
        configureDelegateAndDataSource()
        configureKeyboardType()
    }
    
    private func configureTags() {
        /// textfields:
        ingredientNameTextfield.tag = 1
        countTextfield.tag = 2
        
        /// mainButton:
        addButton.tag = 1
        cancelButton.tag = 2
    }
    
    private func configureDelegateAndDataSource() {
        /// textfields:
        ingredientNameTextfield.delegate = self
        countTextfield.delegate = self
        
        /// picker:
        valueTypeCell.delegate = self
        
        /// mainButton:
        addButton.delegate = self
        cancelButton.delegate = self
        
        valueTypePickerView.delegate = self
        valueTypePickerView.dataSource = self
    }
    
    private func configureKeyboardType() {
        countTextfield.keyboardType = .decimalPad
    }
}

// MARK: Gestures: TextfieldWithIconCellDelegate & PickerButtonWithIconCellDelegate

extension AddIngredientSheetVC: TextfieldWithIconRowDelegate, PickerWithIconRowDelegate, MainActionButtonDelegate {
    func textFieldDidChange(_ textfield: TextfieldWithIconRow, didUpdateText text: String) {
        switch textfield.tag {
        case 1:
            if let text = textfield.textField.text {
                viewModel.igredientName = text
            }
        case 2:
            if let text = textfield.textField.text {
                viewModel.igredientValue = text
            }
        default: break
        }
    }
    
    func textFieldDidBeginEditing(_ textfield: TextfieldWithIconRow, didUpdateText text: String) {
        switch textfield.tag {
        case 1:
            if let text = textfield.textField.text {
                viewModel.igredientName = text
            }
        case 2:
            if let text = textfield.textField.text {
                viewModel.igredientValue = text
            }
        default: break
        }
    }
    
    // Textfield
    func textFieldDidEndEditing(_ textfield: TextfieldWithIconRow, didUpdateText text: String) {
        switch textfield.tag {
        case 1:
            if let text = textfield.textField.text {
                viewModel.igredientName = text
            }
        case 2:
            if let text = textfield.textField.text {
                viewModel.igredientValue = text
            }
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // turn off keyboard
        return true
    }
    
    // Picker
    func pickerWithIconRowTappped(_ cell: PickerWithIconRow) {
        popUpPicker(for: valueTypePickerView, title: "Select ingredient value type")
    }
    
    // Add & Cancel buttons
    func mainActionButtonTapped(_ cell: MainActionButton) {
        switch cell.tag {
        case 1:
            /// add button
            cell.onTapAnimation()
            
            let success = viewModel.addIngredientToList()
            if success {
                coordinator.dismissVC()
            } else {
                ingredientNameTextfield.setPlaceholderColor(.red)
                countTextfield.setPlaceholderColor(.red)
                valueTypeCell.setPlaceholderColor(.red)
            }
        case 2:
            cell.onTapAnimation()
            coordinator.dismissVC()
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
        return viewModel.valueTypeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let reuseLabel = view as? UILabel {
            label = reuseLabel
        } else {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
            label.textAlignment = .center
        }
        label.text = viewModel.valueTypeArray[row]
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedRow = viewModel.valueTypeArray[row]
        valueTypeCell.textOnButton.text = selectedRow
        valueTypeCell.textOnButton.textColor = .ui.primaryText
        viewModel.igredientValueType = selectedRow
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
 
            let selectedValueType = self.viewModel.valueTypeArray[selectedRow]
            self.valueTypeCell.textOnButton.text = selectedValueType
            self.valueTypeCell.textOnButton.textColor = .ui.primaryText
            self.viewModel.igredientValueType = selectedValueType
        })
        
        selectAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(selectAction)
        present(alert, animated: true, completion: nil)
    }
}
