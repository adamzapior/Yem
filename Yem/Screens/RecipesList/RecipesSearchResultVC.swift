//
//  RecipesSearchResultVC.swift
//  Yem
//
//  Created by Adam Zapiór on 25/07/2024.
//

import Kingfisher
import LifetimeTracker
import SnapKit
import UIKit

class RecipesSearchResultsVC: UIViewController {
    let coordinator: RecipesListCoordinator
    let viewModel: RecipesListVM

    private var tableView = UITableView()

    private let emptyTableLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.secondaryText
    )

    // MARK: - Lifecycle

    init(coordinator: RecipesListCoordinator, viewModel: RecipesListVM) {
        self.coordinator = coordinator
        self.viewModel = viewModel
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
        setupTableView()
        setupEmptyTableLabel()
        setupVoiceOverAccessibility()
        
        viewModel.delegateRecipesSearchResult = self
    }

    // MARK: - UI Setup

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecipeSearchResultCell.self, forCellReuseIdentifier: RecipeSearchResultCell.id)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupEmptyTableLabel() {
        view.addSubview(emptyTableLabel)
        emptyTableLabel.text = "No recipes found"
        emptyTableLabel.numberOfLines = 0

        emptyTableLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    /// method for setting custom voice over commands without elements from TableView
    private func setupVoiceOverAccessibility() {
        emptyTableLabel.isAccessibilityElement = true

        if emptyTableLabel.isHidden == false {
            emptyTableLabel.accessibilityLabel = emptyTableLabel.text
            emptyTableLabel.accessibilityHint = "Add recipes to see them in the list"
        }
    }
}

// MARK: - Delegates

extension RecipesSearchResultsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipe = viewModel.filteredRecipes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeSearchResultCell.id, for: indexPath) as! RecipeSearchResultCell
        cell.selectionStyle = .none
        cell.recipeImage.image = nil

        cell.configure(
            with: recipe,
            image: nil,
            localFileManager: viewModel.localFileManager,
            imageFetcherManager: viewModel.imageFetcherManager
        )

        cell.isAccessibilityElement = true
        cell.accessibilityValue = "\(recipe.name) with perp time \(recipe.getPerpTimeString()) and \(recipe.spicy.displayName) spicy level"

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128.VAdapted
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let recipe = viewModel.filteredRecipes[indexPath.row]
        coordinator.navigateToRecipeDetail(with: recipe)
    }
}

extension RecipesSearchResultsVC: RecipesSearchResultDelegate {
    func reloadTable() {
        tableView.reloadData()
        
        if viewModel.filteredRecipes.isEmpty {
            emptyTableLabel.isHidden = false
        } else {
            emptyTableLabel.isHidden = true
        }
    }
}

#if DEBUG
extension RecipesSearchResultsVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
