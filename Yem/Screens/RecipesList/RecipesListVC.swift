//
//  RecipesListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import UIKit

import UIKit

final class RecipesListVC: UIViewController {
    var coordinator: RecipesListCoordinator
    var viewModel: RecipesListVM

    var collectionView: UICollectionView!

    // MARK: - Lifecycle

    init(coordinator: RecipesListCoordinator, viewModel: RecipesListVM) {
        self.coordinator = coordinator
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
        title = "Recipes"

        setupNavigationBar()
        setupCollectionView()

        Task {
            await viewModel.loadRecipes()

            await viewModel.searchRecipesByName("XD")
        }
    }

    // MARK: UI Setup

    private func setupCollectionView() {
        var layout = setupCollectionViewLayout() // Use the custom layout method
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.showsHorizontalScrollIndicator = false

        collectionView.register(RecipeCell.self, forCellWithReuseIdentifier: RecipeCell.id)

        view.addSubview(collectionView)
    }

    private func setupCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()

        let spacing: CGFloat = 1
        let padding: CGFloat = 5
        layout.sectionInset = UIEdgeInsets(top: 10, left: padding, bottom: 10, right: padding)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing

        return layout
    }
}

// MARK: - Delegates

extension RecipesListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.recipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCell.id, for: indexPath) as! RecipeCell
        let data = viewModel.recipes[indexPath.row]
        cell.configure(with: data)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 5
        let spacing: CGFloat = 1

        let totalSpacing = spacing * (2 - 1)
        let availableWidth = collectionView.bounds.width - (padding * 2) - totalSpacing
        let widthPerItem = availableWidth / 2

        let height: CGFloat = 170

        return CGSize(width: widthPerItem, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedRecipe = viewModel.recipes[indexPath.row]

        coordinator.navigateToRecipeDetail(with: selectedRecipe)
    }
}

extension RecipesListVC: RecipesListVMDelegate {
    func reloadTable() {
        collectionView.reloadData()
    }
}

// MARK: - Navigation

extension RecipesListVC {
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipeButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .orange
    }

    @objc func addRecipeButtonTapped() {
        coordinator.goToAddRecipeScreen()
    }
}
