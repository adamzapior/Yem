//
//  RecipesListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import LifetimeTracker
import SnapKit
import UIKit

final class RecipesListVC: UIViewController {
    weak var coordinator: RecipesListCoordinator?
    let viewModel: RecipesListVM

    private let emptyTableLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.secondaryText
    )
    private var collectionView: UICollectionView!

    lazy var searchResultVC = RecipesSearchResultsVC(
        coordinator: coordinator!,
        viewModel: viewModel
    )
    private var searchController: UISearchController!

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
        view.backgroundColor = .systemBackground
        title = "Recipes"
        viewModel.delegate = self

        setupNavigationBar()
        setupSearchController()
        setupCollectionView()
        setupEmptyTableLabel()

        Task {
            viewModel.loadRecipes()
        }
    }

    // MARK: - UI Setup

    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: searchResultVC)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search your recipes"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func setupCollectionView() {
        let layout = setupLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)

        collectionView.collectionViewLayout = setupLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RecipeCell.self, forCellWithReuseIdentifier: RecipeCell.id)
        collectionView.register(RecipesSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecipesSectionHeaderView.reuseIdentifier)

        collectionView.showsVerticalScrollIndicator = false

        view.addSubview(collectionView)
    }

    private func setupLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
            let section = self.viewModel.sections[sectionIndex]

            let sectionName = section.title

            switch sectionName {
            case RecipeCategory.breakfast, RecipeCategory.desserts, RecipeCategory.snacks, RecipeCategory.beverages, RecipeCategory.vegan, RecipeCategory.vegetarian:

                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(250), heightDimension: .absolute(170))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(250), heightDimension: .absolute(170))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 7
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5)
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem(forSection: sectionIndex)]
                return section
            case RecipeCategory.lunch, RecipeCategory.dinner:
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(250), heightDimension: .absolute(250))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(250), heightDimension: .absolute(250))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 7
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5)
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem(forSection: sectionIndex)]
                return section
            case RecipeCategory.appetizers, RecipeCategory.sideDishes, RecipeCategory.notSelected:
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(170), heightDimension: .absolute(170))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(170), heightDimension: .absolute(170))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 7
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5)
                section.boundarySupplementaryItems = [self.supplementaryHeaderItem(forSection: sectionIndex)]
                return section
            }
        }
    }

    private func supplementaryHeaderItem(forSection section: Int) -> NSCollectionLayoutBoundarySupplementaryItem {
        if viewModel.sections[section].items.isEmpty {
            return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.0001)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        } else {
            return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        }
    }

    private func setupEmptyTableLabel() {
        view.addSubview(emptyTableLabel)
        emptyTableLabel.text = "Your recipes list is empty"

        emptyTableLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: - Delegates

extension RecipesListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.filterRecipes(query: searchText)
    }
}

extension RecipesListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = viewModel.sections[indexPath.section]
        let recipe = section.items[indexPath.item]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecipeCell.id, for: indexPath) as! RecipeCell
        cell.recipeImage.image = nil

        cell.configure(
            with: recipe,
            image: nil,
            localFileManager: viewModel.localFileManager,
            imageFetcherManager: viewModel.imageFetcherManager
        )

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if viewModel.sections[section].items.isEmpty {
            return .zero
        } else {
            return CGSize(width: collectionView.bounds.width, height: 25)
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if viewModel.sections[indexPath.section].items.isEmpty {
            return UICollectionReusableView(frame: .zero)
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecipesSectionHeaderView.reuseIdentifier, for: indexPath) as! RecipesSectionHeaderView

            let section = viewModel.sections[indexPath.section]
            let sectionTitle = section.title

            headerView.configure(title: sectionTitle.rawValue)

            return headerView
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = viewModel.sections[indexPath.section]
        let recipe = section.items[indexPath.item]

        coordinator?.navigateToRecipeDetail(with: recipe)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: 0, y: 50)
        cell.alpha = 0

        // Calculate delay based on the position in the section
        let delay = Double(indexPath.item) * 0.1

        // Animate the cell appearance
        UIView.animate(withDuration: 0.5, delay: delay, options: [.curveEaseInOut], animations: {
            cell.transform = .identity
            cell.alpha = 1
        }, completion: nil)
    }
}

extension RecipesListVC: RecipesListVMDelegate {
    func reloadTable() {
        collectionView.reloadData()

        if viewModel.sections.isEmpty {
            emptyTableLabel.isHidden = false
        } else {
            emptyTableLabel.isHidden = true
        }
    }
}

// MARK: - Navigation

extension RecipesListVC {
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(settingsButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .ui.theme
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipeButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .ui.theme
    }

    @objc func addRecipeButtonTapped() {
        coordinator?.navigateToAddRecipeScreen()
    }

    @objc func settingsButtonTapped() {
        coordinator?.navigateToSettings()
    }
}

#if DEBUG
extension RecipesListVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
