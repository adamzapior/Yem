//
//  RecipesSearchResultVC.swift
//  Yem
//
//  Created by Adam Zapiór on 25/07/2024.
//

import Combine
import LifetimeTracker
import SnapKit
import UIKit

class RecipesSearchResultsVC: UIViewController {
    private weak var coordinator: RecipesListCoordinator?
    private let viewModel: RecipesListVM

    private var tableView = UITableView()

    private let emptyTableLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.secondaryText,
        textAlignment: .center
    )

    private var cancellables = Set<AnyCancellable>()

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

        observeViewModelEventOutput()
        viewModel.inputSearchResultsEvent.send(.viewDidLoad)
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

        emptyTableLabel.isHidden = true
    }

    private func setupVoiceOverAccessibility() {
        emptyTableLabel.isAccessibilityElement = true

        emptyTableLabel.accessibilityLabel = emptyTableLabel.text
        emptyTableLabel.accessibilityHint = "Add recipes to see them in the list"
    }
}

// MARK: - Observe ViewModel Output & UI actions

extension RecipesSearchResultsVC {
    private func observeViewModelEventOutput() {
        viewModel.outputSearchResultsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                self.handleViewModelOutput(event: event)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Handle Output & UI Actions

extension RecipesSearchResultsVC {
    private func handleViewModelOutput(event: RecipesListVM.RecipesSearchResultOutput) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            switch event {
            case .reloadTable:
                tableView.reloadData()
            case .updateListStatus(isEmpty: let result):
                switch result {
                case true:
                    emptyTableLabel.isHidden = false
                case false:
                    emptyTableLabel.isHidden = true
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension RecipesSearchResultsVC: UITableViewDataSource {
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
}

// MARK: - UITableViewDelegate

extension RecipesSearchResultsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128.VAdapted
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let recipe = viewModel.filteredRecipes[indexPath.row]
        coordinator?.navigateTo(.recipeDetailsScreen, recipe: recipe)
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension RecipesSearchResultsVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
