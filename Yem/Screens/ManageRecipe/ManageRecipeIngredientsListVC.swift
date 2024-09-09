//
//  AddRecipe2VC.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import Combine
import CombineCocoa
import LifetimeTracker
import UIKit

final class ManageRecipeIngredientsListVC: UIViewController {
    private weak var coordinator: ManageRecipeCoordinator?
    private let viewModel: ManageRecipeVM
        
    private let pageStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 4
        return sv
    }()
        
    private let tableView = UITableView()
    private let tableViewHeader = IngredientsTableHeaderView()
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
        title = "Ingredients"
            
        setupNavigationBarButtons()
        
        setupTableView()
        setupTableViewHeader()
        setupTableViewFooter()
        setupEmptyTableLabel()
        
        observeViewModelOutput()
        observeActionButton()
        
        setupAnimations()
        
        viewModel.inputIngredientsListEvent.send(.viewDidLoad)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.layoutIfNeeded()
        tableView.tableFooterView = tableViewFooter
    }
    
    // MARK: - Setup UI
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(IngredientsCell.self, forCellReuseIdentifier: IngredientsCell.id)
        
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
        tableViewHeader.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30)
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
    
    private func setupAnimations() {
        emptyTableLabel.animateFadeIn()
    }
}

// MARK: - Observe ViewModel Output & UI actions

extension ManageRecipeIngredientsListVC {
    private func observeViewModelOutput() {
        viewModel.outputIngredientsListEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                handleViewModelOutput(for: event)
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

extension ManageRecipeIngredientsListVC {
    private func handleViewModelOutput(for event: ManageRecipeVM.IngredientsListOutput) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            switch event {
            case .reloadTable:
                tableView.reloadData()
            case .updateListStatus(isEmpty: let value):
                handleEmptyLabelVisible(value)
                handleAccessibilityUpdate(isTableEmpty: value)
            case .validationError(let type):
                handleValidationError(type)
            }
        }
    }

    private func handleActionButtonEvent() {
        navigateToAddIngredientSheet()
    }
    
    private func handleEmptyLabelVisible(_ value: Bool) {
        switch value {
        case true:
            emptyTableLabel.isHidden = false
        case false:
            emptyTableLabel.isHidden = true
        }
    }
    
    private func handleAccessibilityUpdate(isTableEmpty: Bool) {
        emptyTableLabel.accessibilityHint = isTableEmpty ? "Add ingredient to list" : nil
    }
    
    func handleValidationError(_ type: ManageRecipeVM.ErrorType.Ingredients) {
        if type == .ingredientsList {
            emptyTableLabel.textColor = .ui.placeholderError
        }
    }
}

// MARK: - UITableViewDataSource

extension ManageRecipeIngredientsListVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ingredientsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IngredientsCell.id, for: indexPath) as? IngredientsCell else {
            fatalError("IngredientsCell error")
        }

        cell.configure(with: viewModel.ingredientsList[indexPath.row])
        
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = "This is \(indexPath.row + 1) added ingrendient cell"
        cell.accessibilityValue = "\(viewModel.ingredientsList[indexPath.row].value) \(viewModel.ingredientsList[indexPath.row].valueType) \(viewModel.ingredientsList[indexPath.row].name)"
        
        cell.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                DispatchQueue.main.async { [weak self] in
                    self?.handleCellEvent(indexPath: indexPath)
                }
            }
            .store(in: &cell.cancellables)

        return cell
    }
    
    // MARK: Cell Event

    func handleCellEvent(indexPath: IndexPath) {
        viewModel.removeIngredientFromList(at: indexPath.row)
    }
}

// MARK: -  UITableViewDelegate

extension ManageRecipeIngredientsListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - NavigationItems & Navigation

extension ManageRecipeIngredientsListVC {
    func setupNavigationBarButtons() {
        let nextButtonItem = UIBarButtonItem(
            title: "Next",
            style: .plain,
            target: self,
            action: #selector(nextButtonTapped)
        )
        navigationItem.rightBarButtonItem = nextButtonItem
    }
    
    @objc func nextButtonTapped(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateTo(.instructions)
        }
    }

    func navigateToAddIngredientSheet() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateTo(.addIngredient)
        }
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension ManageRecipeIngredientsListVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
