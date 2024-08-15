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
    var viewModel: RecipesListVM
    var tableView: UITableView!

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
        viewModel.delegateRecipesSearchResult = self
    }

    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
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

    private func animateCells() {
        let visibleCells = tableView.visibleCells
        let tableViewHeight = tableView.bounds.height

        for (index, cell) in visibleCells.enumerated() {
            let delay = 0.05 * Double(index)
            let cellPosition = cell.frame.origin.y + cell.frame.height
            let offset = tableViewHeight - cellPosition

            cell.transform = CGAffineTransform(translationX: 0, y: offset)
            cell.alpha = 0

            UIView.animate(withDuration: 0.5,
                           delay: delay,
                           options: [.curveEaseInOut],
                           animations: {
                               cell.transform = .identity
                               cell.alpha = 1
                           }, completion: nil)
        }
    }
}

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
        animateCells()
    }
}

#if DEBUG
    extension RecipesSearchResultsVC: LifetimeTrackable {
        class var lifetimeConfiguration: LifetimeConfiguration {
            return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
        }
    }
#endif
