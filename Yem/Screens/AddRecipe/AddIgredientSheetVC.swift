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
    let countTextfield = TextfieldWithIconCell(iconImage: "bag.badge.plus", placeholderText: "Enter count", textColor: .ui.secondaryText)
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
    
    // MARK: - Lifecycle
    
    init(viewModel: AddRecipeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        let smallDetentId = UISheetPresentationController.Detent.Identifier("small")
        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallDetentId) { context in
            return 300
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

// MARK: Gestures
extension AddIgredientSheetVC: TextfieldWithIconCellDelegate, PickerButtonWithIconCellDelegate {
    func pickerButtonWithIconCellDidTapButton(_ cell: PickerButtonWithIconCell) {
        //
    }
    
    func textFieldDidEndEditing(_ cell: TextfieldWithIconCell, didUpdateText text: String) {
        switch cell.tag {
        case 1:
            if let text = cell.textField.text {
                viewModel.igredientName = text
            }
        case 2:
            if let text = cell.textField.text {
                viewModel.igredientCount = text
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

extension AddIgredientSheetVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
       return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 1
    }
}
