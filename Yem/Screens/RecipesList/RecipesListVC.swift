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
    let coordinator: RecipesListCoordinator
    let viewModel: RecipesListVM

    private var collectionView: UICollectionView!

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
        viewModel.delegate = self

        setupNavigationBar()
        setupCollectionView()

        Task {
            viewModel.loadRecipes()
        }
    }

    // MARK: UI Setup

    private func setupCollectionView() {
        let layout = setupLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)

        collectionView.collectionViewLayout = setupLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RecipeCell.self, forCellWithReuseIdentifier: RecipeCell.id)
        collectionView.register(CustomHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CustomHeaderView.reuseIdentifier)

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
}

// MARK: - Delegates

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

        cell.configure(with: recipe, image: nil)
      

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
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CustomHeaderView.reuseIdentifier, for: indexPath) as! CustomHeaderView

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

        coordinator.navigateToRecipeDetail(with: recipe)
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
        coordinator.navigateToAddRecipeScreen()
    }
}

class CustomHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "CustomHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        addSubview(titleLabel)
        titleLabel.textColor = .ui.secondaryText

        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
