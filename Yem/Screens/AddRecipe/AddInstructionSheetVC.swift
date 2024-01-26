//
//  AddInstructionSheetVC.swift
//  Yem
//
//  Created by Adam Zapiór on 21/01/2024.
//

import UIKit

class AddInstructionSheetVC: UIViewController {
    // MARK: - Properties
    
    var coordinator: AddRecipeCoordinator
    var viewModel: AddRecipeViewModel
    
    // MARK: - View properties
    
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

// MARK: - Gestures

extension AddInstructionSheetVC: MainActionButtonDelegate {
    func mainActionButtonTapped(_ button: MainActionButton) {
        switch button.tag {
        case 1:
            button.onTapAnimation()
            
            let success = viewModel.addInstructionToList()
            if success {
                coordinator.dismissVC()
            } else {
               
            }
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
