//
//  AddIgredientSheetVC.swift
//  Yem
//
//  Created by Adam Zapiór on 16/12/2023.
//

import UIKit

class AddIgredientSheetVC: UIViewController {
    // MARK: - VM
    
    var viewModel: AddRecipeViewModel
    
    // MARK: - View properties
    
    let igredientNameTextfield = TextfieldWithIconCell(iconImage: "info.square", placeholderText: "Enter your igredient name", textColor: .ui.secondaryText)
    let countTextfield = TextfieldWithIconCell(iconImage: "bag.badge.plus", placeholderText: "Enter value", textColor: .ui.secondaryText)
    let valueTypeCell = PickerButtonWithIconCell(iconImage: "note.text.badge.plus", textOnButton: "Select value type")
    let addButton = MainAppButton(title: "Add", backgroundColor: .ui.addBackground!)
    let cancelButton = MainAppButton(title: "Cancel", backgroundColor: .ui.cancelBackground ?? .ui.theme)
    
    let valueTypePickerView = UIPickerView()
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()
    
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2
    
    // MARK: - Lifecycle
    
    init(viewModel: AddRecipeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        let smallDetentId = UISheetPresentationController.Detent.Identifier("small")
        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallDetentId) { _ in
            300
        }
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [smallDetent, smallDetent]
            presentationController.prefersGrabberVisible = true
        }
        
        setupUI()
        setupDelegateForViewComponents()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        stackView.addArrangedSubview(igredientNameTextfield)
        stackView.addArrangedSubview(countTextfield)
        stackView.addArrangedSubview(valueTypeCell)
        stackView.addArrangedSubview(addButton)
        stackView.addArrangedSubview(cancelButton)
    }
}

// MARK: - Delegate & data source items

extension AddIgredientSheetVC {
    func setupDelegateForViewComponents() {
        igredientNameTextfield.tag = 1
        countTextfield.tag = 2

        igredientNameTextfield.delegate = self
        countTextfield.delegate = self
        valueTypeCell.delegate = self
        
        valueTypePickerView.delegate = self
        valueTypePickerView.dataSource = self
    }
}

// MARK: Gestures: TextfieldWithIconCellDelegate & PickerButtonWithIconCellDelegate

extension AddIgredientSheetVC: TextfieldWithIconCellDelegate, PickerButtonWithIconCellDelegate {
    func pickerButtonWithIconCellDidTapButton(_ cell: PickerButtonWithIconCell) {
        popUpPicker(for: valueTypePickerView, title: "Select ingredient value type")
    }
    
    func textFieldDidEndEditing(_ cell: TextfieldWithIconCell, didUpdateText text: String) {
        switch cell.tag {
        case 1:
            if let text = cell.textField.text {
                viewModel.igredientName = text
            }
        case 2:
            if let text = cell.textField.text {
                viewModel.igredientValue = text
            }
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Ukrywa klawiaturę
        return true
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Popup Picker

extension AddIgredientSheetVC {
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

// MARK: -  PickerView Delegate & DataSource methods

extension AddIgredientSheetVC: UIPickerViewDelegate, UIPickerViewDataSource {
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
            label.textAlignment = .center // Dostosuj wyrównanie tekstu
        }
        label.text = viewModel.valueTypeArray[row]
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60 // Ustaw wysokość na 50 lub na inną wartość, której potrzebujesz
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedRow = viewModel.valueTypeArray[row]
        valueTypeCell.textOnButton.text = selectedRow
        valueTypeCell.textOnButton.textColor = .ui.primaryText
        viewModel.igredientValueType = selectedRow
    }
}
