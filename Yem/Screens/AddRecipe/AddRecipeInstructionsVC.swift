//
//  AddRecipeInstructionsVC.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import Foundation
import UIKit

final class AddRecipeInstructionsVC: UIViewController {
    // MARK: - Properties

    let viewModel: AddRecipeViewModel
    let coordinator: AddRecipeCoordinator
    
    // MARK: - View properties

    private let pageStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 4
        return sv
    }()
    
    private let pageCount = 3
    private var pageViews = [UIView]()
    
    private let tableView = UITableView()
    private let tableViewHeader = InstructionTableHeaderView()
    private let tableViewFooter = IngredientsTableFooterView()
    
    private let emptyTableLabel = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.secondaryText)

    
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
        view.backgroundColor = .systemBackground
        viewModel.delegateInstructions = self

        setupNavigationBarButtons()
        setupTableView()
        setupTableViewFooter()
        setupTableViewHeader()
        setupEmptyTableLabel()
        setupEmptyTableLabelisHidden()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(InstructionCell.self, forCellReuseIdentifier: "InstructionCell")
        
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true 

        tableView.backgroundColor = UIColor.ui.background
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableViewFooter() {
        tableViewFooter.delegate = self
        
        tableViewFooter.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 200)
        tableViewFooter.backgroundColor = UIColor.ui.background
        tableView.tableFooterView = tableViewFooter
    }
    
    private func setupTableViewHeader() {
        tableView.addSubview(tableViewHeader)
        tableView.tableHeaderView = tableViewHeader
        tableViewHeader.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 36)
        tableViewHeader.backgroundColor = UIColor.ui.background
    }
    
    private func setupEmptyTableLabel() {
        view.addSubview(emptyTableLabel)
        emptyTableLabel.text = "Your instruction list is empty"

        emptyTableLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupEmptyTableLabelisHidden() {
        if viewModel.instructionList.isEmpty {
            emptyTableLabel.isHidden = false
        } else {
            emptyTableLabel.isHidden = true
        }
        
        emptyTableLabel.textColor = .ui.secondaryText
    }
}

extension AddRecipeInstructionsVC: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate, InstructionCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.instructionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InstructionCell.id, for: indexPath) as? InstructionCell else {
            fatalError("instructionCell error")
        }
        cell.delegate = self
        cell.configure(with: viewModel.instructionList[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem]
    {
        let item = viewModel.instructionList[indexPath.row]
        let itemProvider = NSItemProvider(object: item.text as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView,
                   performDropWith coordinator: UITableViewDropCoordinator)
    {
        if let destinationIndexPath = coordinator.destinationIndexPath,
           let sourceIndexPath = coordinator.items.first?.sourceIndexPath
        {
            coordinator.session.loadObjects(ofClass: NSString.self) { _ in
                let draggedItem = self.viewModel.instructionList[sourceIndexPath.row]
                self.viewModel.instructionList.remove(at: sourceIndexPath.row)
                self.viewModel.instructionList.insert(draggedItem, at: destinationIndexPath.row)
                
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: [sourceIndexPath], with: .fade)
                    tableView.insertRows(at: [destinationIndexPath], with: .fade)
                }, completion: nil)
                
                self.viewModel.updateInstructionIndexes()
                self.tableView.reloadData()
            }
        }
    }
        
    func tableView(_ tableView: UITableView,
                   dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal
    {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func didTapButton(in cell: InstructionCell) {
        DispatchQueue.main.async {
            guard let indexPath = self.tableView.indexPath(for: cell) else { return }
            self.viewModel.removeInstructionFromList(at: indexPath.row)
            self.viewModel.updateInstructionIndexes()
            self.tableView.reloadData()
        }
    }
}

extension AddRecipeInstructionsVC: IngredientsTableFooterViewDelegate {
    func addIconTapped(view: UIView) {
        addInstructionTapped()
    }
}

extension AddRecipeInstructionsVC: AddRecipeInstructionsVCDelegate {
    func reloadInstructionTable() {
        tableView.reloadData()
        setupEmptyTableLabelisHidden()
    }
    
    func delegateInstructionsError(_ type: ValidationErrorTypes) {
        if type == .instructionList {
            emptyTableLabel.textColor = .ui.placeholderError
        }
    }
    
}

// MARK: - Navigation

extension AddRecipeInstructionsVC {
    private func setupNavigationBarButtons() {
        let nextButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = nextButtonItem
    }
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) {
        let result = viewModel.saveRecipe()
        if result {
            coordinator.coordinatorDidFinish()
            coordinator.dismissVCStack()
        } else {
            let errorMessages = viewModel.validationErrors.map { $0.description }.joined(separator: "\n")
            coordinator.presentValidationAlert(title: "We can't save your recipe", message: errorMessages)
        }
    }
    
    private func addInstructionTapped() {
        coordinator.pushVC(for: .addInstruction)
    }
}
