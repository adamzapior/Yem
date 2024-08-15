//
//  AddRecipe2VC.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import LifetimeTracker
import UIKit

final class AddRecipeIngredientsVC: UIViewController {
    // MARK: - ViewModel
    
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
    private let tableViewHeader = IngredientsTableHeaderView()
    private let tableViewFooter = IngredientsTableFooterView()
    
    private let emptyTableLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.secondaryText
    )

    // MARK: - Lifecycle
    
    init(viewModel: AddRecipeViewModel, coordinator: AddRecipeCoordinator) {
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
    
        viewModel.delegateIngredients = self
        
        setupNavigationBarButtons()
        
        setupTableView()
        setupTableViewHeader()
        setupTableViewFooter()
        setupEmptyTableLabel()
        setupEmptyTableLabelisHidden()
        
        setupAnimations()
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
        tableViewFooter.delegate = self
        
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

        emptyTableLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setupEmptyTableLabelisHidden() {
        if viewModel.ingredientsList.isEmpty {
            emptyTableLabel.isHidden = false
        } else {
            emptyTableLabel.isHidden = true
        }
        
        emptyTableLabel.textColor = .ui.secondaryText
    }
    
    private func setupAnimations() {
        emptyTableLabel.animateFadeIn()
    }
}

// MARK: -  TableView delegate & data source

extension AddRecipeIngredientsVC: UITableViewDelegate, UITableViewDataSource, IngredientsCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ingredientsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IngredientsCell.id, for: indexPath) as? IngredientsCell else {
            fatalError("IngredientsCell error")
        }

        cell.delegate = self
        cell.configure(with: viewModel.ingredientsList[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func trashTapped(in cell: IngredientsCell) {
        DispatchQueue.main.async {
            guard let indexPath = self.tableView.indexPath(for: cell) else { return }
            self.viewModel.removeIngredientFromList(at: indexPath.row)
        }
    }
}

extension AddRecipeIngredientsVC: AddRecipeIngredientsVCDelegate {
    func delegateIngredientsError(_ type: ValidationErrorTypes) {
        if type == .ingredientList {
            emptyTableLabel.textColor = .ui.placeholderError
        }
    }
    
    func reloadIngredientsTable() {
        tableView.reloadData()
        setupEmptyTableLabelisHidden()
    }
}

extension AddRecipeIngredientsVC: IngredientsTableFooterViewDelegate {
    func addIconTapped(view: UIView) {
        addIgredientTapped()
    }
}

// MARK: - Navigation

extension AddRecipeIngredientsVC {
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
        coordinator.navigateTo(.instructions)
    }

    func addIgredientTapped() {
        coordinator.navigateTo(.addIngredient)
    }
}

#if DEBUG
extension AddRecipeIngredientsVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
