//
//  AddRecipeInstructionsVC.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import Combine
import CombineCocoa
import Foundation
import LifetimeTracker
import UIKit

final class ManageRecipeInstructionsListVC: UIViewController {
    private weak var coordinator: ManageRecipeCoordinator?
    private let viewModel: ManageRecipeVM
    
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
    
    private let emptyTableLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.secondaryText,
        textAlignment: .center
    )

    private var cancellables = Set<AnyCancellable>()
    
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
        view.backgroundColor = .systemBackground
        title = "Instructions"

        setupNavigationBarButtons()
        setupTableView()
        setupTableViewFooter()
        setupTableViewHeader()
        setupEmptyTableLabel()
        
        observeViewModelOutput()
        observeActionButton()
        
        viewModel.inputInstructionsListEvent.send(.viewDidLoad)
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
        emptyTableLabel.text = "Your ingredient list is empty"
        emptyTableLabel.numberOfLines = 0

        emptyTableLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        emptyTableLabel.isHidden = true
    }
}

// MARK: - Observe ViewModel Output & UI actions

extension ManageRecipeInstructionsListVC {
    private func observeViewModelOutput() {
        viewModel.outputInstructionsListPublisher
            .sink { [unowned self] event in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    switch event {
                    case .reloadTable:
                        tableView.reloadData()
                    case .updateListStatus(isEmpty: let value):
                        setEmptyLabelVisible(value)
                        handleAccessibilityUpdate(isEmpty: value)
                    case .validationError(let type):
                        handleValidationError(type)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func observeActionButton() {
        tableViewFooter.addButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                self.handleActionButtonEvent()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Handle Output & UI Actions

extension ManageRecipeInstructionsListVC {
    private func handleActionButtonEvent() {
        navigateToAddInstructionSheet()
    }
    
    private func setEmptyLabelVisible(_ isListEmpty: Bool) {
        switch isListEmpty {
        case true:
            emptyTableLabel.isHidden = false
        case false:
            emptyTableLabel.isHidden = true
        }
    }
    
    private func handleAccessibilityUpdate(isEmpty: Bool) {
        emptyTableLabel.accessibilityHint = isEmpty ? "Add instruction to list" : nil
    }
    
    private func handleValidationError(_ type: ManageRecipeVM.ErrorType.Instructions) {
        if type == .instructionList {
            emptyTableLabel.textColor = .ui.placeholderError
        }
    }
}

// MARK: UITableViewDataSource

extension ManageRecipeInstructionsListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.instructionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InstructionCell.id, for: indexPath) as? InstructionCell else {
            fatalError("instructionCell error")
        }
        cell.configure(with: viewModel.instructionList[indexPath.row])
        
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = "This is \(indexPath.row + 1) added instruction cell"
        cell.accessibilityValue = "\(viewModel.instructionList[indexPath.row].text)"
        
        cell.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                DispatchQueue.main.async { [weak self] in
                    self?.handleCellEvent(indexPath: indexPath)
                }
            }
            .store(in: &cell.cancellables)

        return cell
    }
    
    // MARK: Cell Event

    func handleCellEvent(indexPath: IndexPath) {
        viewModel.removeInstructionFromList(at: indexPath.row)
    }
}

// MARK: UITableViewDelegate & UITableViewDragDelegate & UITableViewDropDelegate

extension ManageRecipeInstructionsListVC: UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(
        _ tableView: UITableView,
        itemsForBeginning session: UIDragSession,
        at indexPath: IndexPath
    ) -> [UIDragItem] {
        let item = viewModel.instructionList[indexPath.row]
        let itemProvider = NSItemProvider(object: item.text as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    func tableView(
        _ tableView: UITableView,
        performDropWith coordinator: UITableViewDropCoordinator
    ) {
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
        
    func tableView(
        _ tableView: UITableView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

// MARK: - NavigationItems & Navigation

extension ManageRecipeInstructionsListVC {
    private func setupNavigationBarButtons() {
        let nextButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = nextButtonItem
    }

    @objc func saveButtonTapped(_ sender: UIBarButtonItem) {
        do {
            try viewModel.saveRecipe()
            popUpToRoot()
        } catch let validationError as ManageRecipeVM.ValidationError {
            let errorMessages = validationError.localizedDescription
            presentValidationAlert(title: "An error occurred", message: errorMessages)
        } catch {
            presentValidationAlert(title: "An error occurred", message: error.localizedDescription)
        }
    }
    
    private func popUpToRoot() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.popUptoRoot()
        }
    }
    
    private func presentValidationAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.presentAlert(
                .validationAlert,
                title: title,
                message: message
            )
        }
    }
    
    private func navigateToAddInstructionSheet() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateTo(.addInstruction)
        }
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension ManageRecipeInstructionsListVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
