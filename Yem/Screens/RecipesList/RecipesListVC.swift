//
//  RecipesListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import Combine
import LifetimeTracker
import SnapKit
import UIKit

final class RecipesListVC: UIViewController {
    private weak var coordinator: RecipesListCoordinator?
    private let viewModel: RecipesListVM

    private lazy var settingsNavItem = UIBarButtonItem(
        image: UIImage(
            systemName: "gearshape"
        ),
        style: .plain,
        target: self,
        action: #selector(settingsButtonTapped)
    )
    private lazy var addRecipeNavItem = UIBarButtonItem(
        image: UIImage(
            systemName: "plus"
        ),
        style: .plain,
        target: self,
        action: #selector(addRecipeButtonTapped)
    )

    private let emptyTableLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.secondaryText
    )

    private lazy var collectionView = UICollectionView()
    private lazy var searchController = UISearchController()

    private lazy var searchResultVC = RecipesSearchResultsVC(
        coordinator: coordinator!,
        viewModel: viewModel
    )

    private let activityIndicatorView = UIActivityIndicatorView()

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
        view.backgroundColor = .systemBackground
        title = "Recipes"

        setupNavigationBar()
        setupSearchController()
        setupCollectionView()
        setupEmptyTableLabel()
        setupActivityIndicatorView()
        setupVoiceOverAccessibility()

        observeViewModelEventOutput()
        viewModel.inputRecipesListEvent.send(.viewDidLoad)
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
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
            let sectionCategory = section.title

            let (itemWidth, itemHeight, groupWidth, groupHeight) = self.dimensionsForSection(sectionCategory)

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(itemWidth),
                                                  heightDimension: .fractionalHeight(itemHeight))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(groupWidth),
                                                   heightDimension: .fractionalHeight(groupHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let layoutSection = NSCollectionLayoutSection(group: group)
            layoutSection.orthogonalScrollingBehavior = .continuous
            layoutSection.interGroupSpacing = 7
            layoutSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5)
            layoutSection.boundarySupplementaryItems = [self.supplementaryHeaderItem(forSection: sectionIndex)]

            return layoutSection
        }
    }

    private func dimensionsForSection(_ category: RecipeCategoryModel) -> (itemWidth: CGFloat, itemHeight: CGFloat, groupWidth: CGFloat, groupHeight: CGFloat) {
        switch category {
        case .breakfast, .desserts, .snacks, .beverages, .vegan, .vegetarian:
            return (1.0, // itemWidth
                    1.0, // itemHeight
                    0.8, // groupWidth
                    0.25) // groupHeight
        case .lunch, .dinner:
            return (1.0, // itemWidth
                    1.0, // itemHeight
                    0.8, // groupWidth
                    0.35) // groupHeight
        case .appetizers, .sideDishes, .notSelected:
            return (1.0, // itemWidth
                    1.0, // itemHeight
                    0.8, // groupWidth
                    0.25) // groupHeight
        default:
            return (1.0, // itemWidth
                    1.0, // itemHeight
                    0.8, // groupWidth
                    0.25) // groupHeight
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
        emptyTableLabel.numberOfLines = 0

        emptyTableLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        emptyTableLabel.isHidden = true
    }

    private func setupActivityIndicatorView() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()

        activityIndicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    private func hideActivityIndicatorView() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }

    /// method for setting custom voice over commands without elements from CollectionView
    private func setupVoiceOverAccessibility() {
        settingsNavItem.isAccessibilityElement = true
        settingsNavItem.accessibilityLabel = "Settings button"
        settingsNavItem.accessibilityHint = "Open settings screen"

        addRecipeNavItem.isAccessibilityElement = true
        addRecipeNavItem.accessibilityLabel = "Add recipe button"
        addRecipeNavItem.accessibilityHint = "Open add recipe screen"
    }
}

// MARK: - Observed ViewModel Output & UI actions

extension RecipesListVC {
    private func observeViewModelEventOutput() {
        viewModel.outputPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                self.handleViewModelOutput(event: event)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Handle Output & UI Actions

extension RecipesListVC {
    private func handleViewModelOutput(event: RecipesListVM.RecipesListOutput) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            switch event {
            case .reloadTable:
                collectionView.reloadData()
            case .initialDataFetched:
                hideActivityIndicatorView()
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

// MARK: - UISearchResultsUpdating

extension RecipesListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.inputSearchResultsEvent.send(.sendQueryValue(searchText))
    }
}

// MARK: - UICollectionViewDataSource

extension RecipesListVC: UICollectionViewDataSource {
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
        cell.prepareForReuse()

        cell.configure(
            with: recipe,
            image: nil,
            localFileManager: viewModel.localFileManager,
            imageFetcherManager: viewModel.imageFetcherManager
        )

        cell.isAccessibilityElement = true
        cell.accessibilityLabel = "Recipe from \(section.title.displayName) category"
        cell.accessibilityValue = "\(recipe.name) with prep time \(recipe.getPrepTimeString()) and \(recipe.spicy.displayName) spicy level"

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if viewModel.sections[indexPath.section].items.isEmpty {
            return UICollectionReusableView(frame: .zero)
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: RecipesSectionHeaderView.reuseIdentifier, for: indexPath) as! RecipesSectionHeaderView

            let section = viewModel.sections[indexPath.section]
            let sectionTitle = section.title

            headerView.configure(title: sectionTitle.displayName)

            headerView.isAccessibilityElement = true
            headerView.accessibilityLabel = "\(sectionTitle.displayName) section"
            headerView.accessibilityValue = "Contains \(section.items.count) recipes"

            return headerView
        }
    }
}

// MARK: - UICollectionViewDelegate

extension RecipesListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if viewModel.sections[section].items.isEmpty {
            return .zero
        } else {
            return CGSize(width: collectionView.bounds.width, height: 25)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = viewModel.sections[indexPath.section]
        let recipe = section.items[indexPath.item]

        coordinator?.navigateTo(.recipeDetailsScreen, recipe: recipe)
    }
}

// MARK: - NavigationItems & Navigation

extension RecipesListVC {
    func setupNavigationBar() {
        navigationItem.setLeftBarButton(settingsNavItem, animated: true)
        navigationItem.setRightBarButton(addRecipeNavItem, animated: true)
    }

    @objc func addRecipeButtonTapped() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateTo(.addRecipeScreen)
        }
    }

    @objc func settingsButtonTapped() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateTo(.settingsScreen)
        }
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension RecipesListVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
