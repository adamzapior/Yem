//
//  RecipeDetailsVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import Combine
import LifetimeTracker
import SnapKit
import UIKit

final class RecipeDetailsVC: UIViewController {
    private weak var coordinator: RecipeDetailsCoordinator?
    private let viewModel: RecipeDetailsVM
        
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var photoView = PhotoView(
        frame: .zero,
        iconString: "photo",
        enableAnimations: false
    )
    
    private let detailsSubtitleLabel = UILabel()
    private let detailsContainer = UIView()
    private let nameView = DetailsView()
    private let categoryView = DetailsView()
    private let servingView = DetailsView()
    private let prepTiemView = DetailsView()
    private let spicyView = DetailsView()
    private let difficultyView = DetailsView()
    
    private let ingredientsSubtitleLabel = UILabel()
    private let ingredientsContainer = UIView()
    
    private let instructionsSubtitleLabel = UILabel()
    private let instructionsContainer = UIView()
    
    private var cancellables = Set<AnyCancellable>()

    private lazy var cookNavItem = UIBarButtonItem(
        image: UIImage(systemName: "play"),
        style: .plain,
        target: self,
        action: #selector(playButtonTapped)
    )
        
    private lazy var basketNavItem = UIBarButtonItem(
        image: UIImage(
            systemName: "basket"
        ),
        style: .plain,
        target: self,
        action: #selector(basketButtonTapped)
    )
    
    private lazy var bookmarkNavItem = UIBarButtonItem(
        image: UIImage(
            systemName: "\(bookmarkIconString)"
        ),
        style: .plain,
        target: self,
        action: #selector(bookmarkButtonTapped)
    )

    private lazy var pencilNavItem = UIBarButtonItem(
        image: UIImage(
            systemName: "pencil"
        ),
        style: .plain,
        target: self,
        action: #selector(pencilButtonTapped)
    )

    // TODO: FIX!!!
    private lazy var trashNavItem = UIBarButtonItem(
        image: UIImage(systemName: "trash"),
        style: .plain,
        target: self,
        action: #selector(trashItemButtonTapped)
    )
    
    private lazy var moreNavItem: UIBarButtonItem = {
        let editAction = UIAction(
            title: "Edit",
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.pencilButtonTapped(self!.pencilNavItem)
        }
        
        let deleteAction = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.trashItemButtonTapped(self!.trashNavItem)
        }
        
        let menu = UIMenu(title: "", children: [editAction, deleteAction])
        
        let button = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), menu: menu)
        return button
    }()
    
    private var bookmarkIconString: String
    private let bookmarkIconFilled: String = "bookmark.fill"
    private let bookmarkIconEmpty: String = "bookmark"
    
    // MARK: - Lifecycle

    init(viewModel: RecipeDetailsVM, coordinator: RecipeDetailsCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        
        if viewModel.recipe.isFavourite {
            bookmarkIconString = bookmarkIconFilled
        } else {
            bookmarkIconString = bookmarkIconEmpty
        }
        
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
        setupNavigationBarButtons()
        
        setupScrollView()
        setupContentView()
        
        setupPhotoView()
        setupDetailsSubtitleLabel()
        setupDetailsContainer()
        setupRecipeDetailsViews()
        setupIngredientsSubtitleLabel()
        setupIngredientsContainer()
        setupInstructionsSubtitleLabel()
        setupInstructionsContainer()
        
        setupVoiceOverAccessibility()
        
        observedViewModelOutput()
        viewModel.inputEvent.send(.viewDidLoad)
    }

    // MARK: - UI Setup

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
    
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupContentView() {
        scrollView.addSubview(contentView)
    
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
    
        let hConstant = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        hConstant.isActive = true
        hConstant.priority = UILayoutPriority(50) /// always less priority than ScrollView
    }
    
    private func setupPhotoView() {
        contentView.addSubview(photoView)
    
        photoView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(200)
        }
    }
    
    private func setupDetailsSubtitleLabel() {
        contentView.addSubview(detailsSubtitleLabel)
         
        detailsSubtitleLabel.text = "Details"
        detailsSubtitleLabel.font = UIFont.systemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize,
            weight: .semibold
        )
        detailsSubtitleLabel.textColor = .ui.primaryText
         
        detailsSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(photoView.snp.bottom).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(18)
        }
    }
    
    private func setupDetailsContainer() {
        contentView.addSubview(detailsContainer)
        
        detailsContainer.snp.makeConstraints { make in
            make.top.equalTo(detailsSubtitleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(18)
        }
    }
    
    private func setupRecipeDetailsViews() {
        detailsContainer.addSubview(nameView)
        detailsContainer.addSubview(categoryView)
        detailsContainer.addSubview(servingView)
        detailsContainer.addSubview(prepTiemView)
        detailsContainer.addSubview(spicyView)
        detailsContainer.addSubview(difficultyView)
        
        nameView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        categoryView.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }
        
        servingView.snp.makeConstraints { make in
            make.top.equalTo(categoryView.snp.bottom).offset(12)
            make.leading.equalTo(detailsContainer.snp.leading)
            make.width.equalTo(detailsContainer.snp.width).multipliedBy(0.5).offset(-4)
            make.height.equalTo(prepTiemView.snp.height)
        }
      
        prepTiemView.snp.makeConstraints { make in
            make.top.equalTo(categoryView.snp.bottom).offset(12)
            make.trailing.equalTo(detailsContainer.snp.trailing)
            make.width.equalTo(difficultyView.snp.width)
        }
        
        spicyView.snp.makeConstraints { make in
            make.top.equalTo(servingView.snp.bottom).offset(12)
            make.leading.equalTo(detailsContainer.snp.leading)
            make.width.equalTo(detailsContainer.snp.width).multipliedBy(0.5).offset(-4)
            make.bottom.equalToSuperview()
        }
      
        difficultyView.snp.makeConstraints { make in
            make.top.equalTo(servingView.snp.bottom).offset(12)
            make.trailing.equalTo(detailsContainer.snp.trailing)
            make.width.equalTo(spicyView.snp.width)
            make.bottom.equalToSuperview()
        }
        
        nameView.configure(
            titleText: "Name",
            valueText: viewModel.recipe.name
        )
        categoryView.configure(
            titleText: "Category",
            valueText: viewModel.recipe.category.rawValue
        )
        servingView.configure(
            titleText: "Serving",
            valueText: viewModel.recipe.serving
        )
        
        prepTiemView.configure(
            titleText: "Prep time",
            valueText: "\(viewModel.recipe.perpTimeHours)h \(viewModel.recipe.perpTimeMinutes)min"
        )
        spicyView.configure(
            titleText: "Spicy",
            valueText: viewModel.recipe.spicy.rawValue
        )
        difficultyView.configure(
            titleText: "Difficulty",
            valueText: viewModel.recipe.difficulty.rawValue
        )
    }
    
    private func setupIngredientsSubtitleLabel() {
        contentView.addSubview(ingredientsSubtitleLabel)
         
        ingredientsSubtitleLabel.text = "Ingredients"
        ingredientsSubtitleLabel.font = UIFont.systemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize,
            weight: .semibold
        )
        ingredientsSubtitleLabel.textColor = .ui.primaryText
         
        ingredientsSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(detailsContainer.snp.bottom).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(18)
        }
    }
    
    private func setupIngredientsContainer() {
        contentView.addSubview(ingredientsContainer)
        
        ingredientsContainer.backgroundColor = UIColor.ui.primaryContainer
        ingredientsContainer.layer.cornerRadius = 10
        ingredientsContainer.clipsToBounds = true
        
        ingredientsContainer.snp.makeConstraints { make in
            make.top.equalTo(ingredientsSubtitleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.greaterThanOrEqualTo(64)
        }
        
        let ingredientsStackView = UIStackView()
        ingredientsStackView.axis = .vertical
        ingredientsStackView.spacing = 8

        ingredientsStackView.alignment = .fill
        ingredientsStackView.distribution = .fill

        ingredientsContainer.addSubview(ingredientsStackView)
        
        ingredientsStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(18)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview()
        }
         
        for ingredient in viewModel.recipe.ingredientList {
            let ingredientView = IngredientView()
            ingredientView.configure(
                name: ingredient.name.lowercased(),
                value: "\(ingredient.value) \(ingredient.valueType.name.lowercased())"
            )
            
            ingredientView.isAccessibilityElement = true
            ingredientView.accessibilityValue = "\(ingredient.value) \(ingredient.valueType) \(ingredient.name)"

            ingredientsStackView.addArrangedSubview(ingredientView)
        }
    }

    private func setupInstructionsSubtitleLabel() {
        contentView.addSubview(instructionsSubtitleLabel)
         
        instructionsSubtitleLabel.text = "Instructions"
        instructionsSubtitleLabel.font = UIFont.systemFont(
            ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize,
            weight: .semibold
        )
        instructionsSubtitleLabel.textColor = .ui.primaryText
         
        instructionsSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(ingredientsContainer.snp.bottom).offset(12)
            make.leading.equalTo(contentView.snp.leading).offset(18)
        }
    }
    
    private func setupInstructionsContainer() {
        contentView.addSubview(instructionsContainer)
                
        instructionsContainer.snp.makeConstraints { make in
            make.top.equalTo(instructionsSubtitleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-64)
        }
        
        let instructionsStackView = UIStackView()
        instructionsStackView.axis = .vertical
        instructionsStackView.spacing = 12
        instructionsStackView.alignment = .fill
        instructionsStackView.distribution = .fill

        instructionsContainer.addSubview(instructionsStackView)

        instructionsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
         
        for instruction in viewModel.recipe.instructionList.sorted(by: { $0.index < $1.index }) {
            let instructionView = DetailsView()
            instructionView.configure(
                titleText: "STEP \(instruction.index)",
                valueText: instruction.text
            )

            instructionView.isAccessibilityElement = true
            instructionView.accessibilityLabel = "This is \(instruction.index) step."
            instructionView.accessibilityValue = "\(instruction.text)"

            instructionsStackView.addArrangedSubview(instructionView)
        }
    }
    
    private func setupVoiceOverAccessibility() {
        // Navigation bar items:
        cookNavItem.isAccessibilityElement = true
        cookNavItem.accessibilityLabel = "Cooking mode button"
        cookNavItem.accessibilityHint = "Open cooking mode screen"
        
        basketNavItem.isAccessibilityElement = true
        basketNavItem.accessibilityLabel = "Shoping cart button"
        basketNavItem.accessibilityHint = "Add ingredients to shoping list"
        
        bookmarkNavItem.isAccessibilityElement = true
        bookmarkNavItem.accessibilityLabel = "Bookmark button"
        bookmarkNavItem.accessibilityHint = "Add recipe to favourites"

        moreNavItem.isAccessibilityElement = true
        moreNavItem.accessibilityLabel = "Menu button"
        moreNavItem.accessibilityHint = "Open more recipe navigation buttons"
        
        // View:
        
        photoView.isAccessibilityElement = true
        photoView.accessibilityLabel = "Recipe image"
        
        detailsSubtitleLabel.isAccessibilityElement = true
        detailsSubtitleLabel.accessibilityLabel = "Recipe details"
        
        nameView.isAccessibilityElement = true
        nameView.accessibilityLabel = "Recipe name"
        nameView.accessibilityValue = viewModel.recipe.name
        
        categoryView.isAccessibilityElement = true
        categoryView.accessibilityLabel = "Recipe category"
        categoryView.accessibilityValue = viewModel.recipe.category.displayName

        servingView.isAccessibilityElement = true
        servingView.accessibilityLabel = "Recipe serving count"
        servingView.accessibilityValue = viewModel.recipe.serving
        
        prepTiemView.isAccessibilityElement = true
        prepTiemView.accessibilityLabel = "Recipe perp time"
        prepTiemView.accessibilityValue = viewModel.recipe.getPerpTimeString()
        
        spicyView.isAccessibilityElement = true
        spicyView.accessibilityLabel = "Recipe spicy level"
        spicyView.accessibilityValue = viewModel.recipe.spicy.displayName
        
        difficultyView.isAccessibilityElement = true
        difficultyView.accessibilityLabel = "Recipe difficulty level"
        difficultyView.accessibilityValue = viewModel.recipe.difficulty.displayName
        
        ingredientsSubtitleLabel.isAccessibilityElement = true
        ingredientsSubtitleLabel.accessibilityLabel = "Recipe ingredients"
        ingredientsSubtitleLabel.accessibilityHint = "Listed below are all the ingredients needed for this recipe"
        
        instructionsSubtitleLabel.isAccessibilityElement = true
        instructionsSubtitleLabel.accessibilityLabel = "Recipe details"
        instructionsSubtitleLabel.accessibilityHint = "Listed below are all the steps you need to follow to cook this recipe"
    }
}

// MARK: - Observed Output & Handling

extension RecipeDetailsVC {
    private func observedViewModelOutput() {
        viewModel.outputPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                DispatchQueue.main.async { [weak self] in
                    self?.handleViewModelOutput(event: event)
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleViewModelOutput(event: RecipeDetailsVM.Output) {
        switch event {
        case .recipeFavouriteValueChanged(let value):
            changeBookmarkNavItemIcon(isRecipeFavourite: value)
        case .updatePhoto(let image):
            loadPhotoView(image: image)
        }
    }
    
    private func changeBookmarkNavItemIcon(isRecipeFavourite: Bool) {
        switch isRecipeFavourite {
        case true:
            bookmarkNavItem.image = UIImage(systemName: bookmarkIconFilled)
        case false:
            bookmarkNavItem.image = UIImage(systemName: bookmarkIconEmpty)
        }
    }
    
    private func loadPhotoView(image: UIImage) {
        photoView.updatePhoto(with: image)
    }
}

// MARK: - NavigationItems & Navigation

extension RecipeDetailsVC {
    private func setupNavigationBarButtons() {
        navigationItem.setRightBarButtonItems(
            [
                moreNavItem,
                bookmarkNavItem,
                basketNavItem,
                cookNavItem
            ],
            animated: true
        )
    }
    
    @objc func playButtonTapped(_ sender: UIBarButtonItem) {
        coordinator?.navigateTo(.cookingMode)
    }
    
    @objc func basketButtonTapped(_ sender: UIBarButtonItem) {
        let title = "Add ingredients to list"
        let message = "Do you want o add all ingredients to shoping list?"
        
        guard let coordinator = coordinator else { return }
          
        DispatchQueue.main.async { [weak self] in
            coordinator.presentAlert(.addIngredientsToShopingList, title: title, message: message, confirmAction: {
                self?.viewModel.addIngredientsToShopingList()
                coordinator.dismissAlert()
            }) {
                coordinator.dismissAlert()
            }
        }
    }

    @objc func bookmarkButtonTapped(_ sender: UIBarButtonItem) {
        let isFavorite = viewModel.isFavourite

        let title = isFavorite ? "Remove from favorites" : "Add to favorites"
        let message = isFavorite ? "Do you want to remove this recipe from your favorites?" : "Do you want to add this recipe to your favorites?"

        guard let coordinator = coordinator else { return }
          
        DispatchQueue.main.async { [weak self] in
            coordinator.presentAlert(.addToFavourites, title: title, message: message, confirmAction: {
                self?.viewModel.toggleFavouriteStatus()
                coordinator.dismissAlert()
            }) {
                coordinator.dismissAlert()
            }
        }
    }
    
    @objc func pencilButtonTapped(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateTo(.recipeEditor)
        }
    }

    @objc func trashItemButtonTapped(_ sender: UIBarButtonItem) {
        let title = "Remove recipe"
        let message = "Do you want to remove this recipe from your recipes list?"
        
        guard let coordinator = coordinator else { return }

        DispatchQueue.main.async { [weak self] in
            coordinator.presentAlert(.deleteRecipe, title: title, message: message, confirmAction: {
                self?.viewModel.deleteRecipe()
                coordinator.dismissAlert()
            }) {
                coordinator.dismissAlert()
            }
        }
    }
    
    private func dismissAlert() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.dismissAlert()
        }
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension RecipeDetailsVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
