//
//  RecipeDetailsVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import SnapKit
import UIKit

final class RecipeDetailsVC: UIViewController {
    // MARK: - Properties

    let recipe: RecipeModel

    let viewModel: RecipeDetailsVM
    let coordinator: RecipeDetailsCoordinator
    
    // MARK: - View properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    var photoView = PhotoView(frame: .zero, iconString: "photo")
    
    private let detailsSubtitleLabel = UILabel()
    private let detailsContainer = UIView()
    private let nameView = RecipeDetailsView()
    private let categoryView = RecipeDetailsView()
    private let servingView = RecipeDetailsView()
    private let prepTiemView = RecipeDetailsView()
    private let spicyView = RecipeDetailsView()
    private let difficultyView = RecipeDetailsView()
    
    private let ingredientsSubtitleLabel = UILabel()
    private let ingredientsContainer = UIView()
    
    private let instructionsSubtitleLabel = UILabel()
    private let instructionsContainer = UIView()

//    private var isBookmarked = false
    
    var bookmarkIconString: String

    let bookmarkIconFilled: String = "bookmark.fill"
    let bookmarkIconEmpty: String = "bookmark"
    
    lazy var basketNavItem = UIBarButtonItem(image: UIImage(systemName: "basket"), style: .plain, target: self, action: #selector(basketButtonTapped))
    
    lazy var bookmarkNavItem = UIBarButtonItem(image: UIImage(systemName: "\(bookmarkIconString)"), style: .plain, target: self, action: #selector(bookmarkButtonTapped))

    lazy var pencilNavItem = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(pencilButtonTapped))

    lazy var trashNavItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(trashButtonTapped))

    init(recipe: RecipeModel, viewModel: RecipeDetailsVM, coordinator: RecipeDetailsCoordinator) {
        self.recipe = recipe
        self.viewModel = viewModel
        self.coordinator = coordinator
        
        if recipe.isFavourite {
            bookmarkIconString = bookmarkIconFilled
        } else {
            bookmarkIconString = bookmarkIconEmpty
        }
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        viewModel.delegate = self
        
        setupNavigationBarButtons()
        
        setupScrollView()
        setupContentView()
        
        setupPhotoView()
        
        Task {
            await loadPhotoView()
        }
        
        setupDetailsSubtitleLabel()
        setupDetailsContainer()
        setupRecipeDetailsViews()
        
        setupIngredientsSubtitleLabel()
        setupIngredientsContainer()
        
        setupInstructionsSubtitleLabel()
        setupInstructionsContainer()
        
        configureRecipeViewData()
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
    
    private func loadPhotoView() async {
        do {
            if let image = await viewModel.loadRecipeImage() {
                photoView.updatePhoto(with: image)
            }
        }
    }
    
    private func setupDetailsSubtitleLabel() {
        contentView.addSubview(detailsSubtitleLabel)
         
        detailsSubtitleLabel.text = "Details"
        detailsSubtitleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .semibold)
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
        }
      
        prepTiemView.snp.makeConstraints { make in
            make.top.equalTo(categoryView.snp.bottom).offset(12)
            make.trailing.equalTo(detailsContainer.snp.trailing)
            make.width.equalTo(servingView.snp.width)
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
    }
    
    private func setupIngredientsSubtitleLabel() {
        contentView.addSubview(ingredientsSubtitleLabel)
         
        ingredientsSubtitleLabel.text = "Ingredients"
        ingredientsSubtitleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .semibold)
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
         
        for ingredient in recipe.ingredientList {
            let ingredientView = IngredientView()
            ingredientView.configure(name: ingredient.name.lowercased(), value: "\(ingredient.value) \(ingredient.valueType.lowercased())")

            ingredientsStackView.addArrangedSubview(ingredientView)
        }
    }
    
    private func setupInstructionsSubtitleLabel() {
        contentView.addSubview(instructionsSubtitleLabel)
         
        instructionsSubtitleLabel.text = "Instructions"
        instructionsSubtitleLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .semibold)
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
         
        for instruction in recipe.instructionList.sorted(by: { $0.index < $1.index }) {
            let instructionView = RecipeDetailsView()
            instructionView.configure(titleText: "STEP \(instruction.index)", valueText: instruction.text)

            instructionsStackView.addArrangedSubview(instructionView)
        }
    }
    
    private func configureRecipeViewData() {
        nameView.configure(titleText: "Name", valueText: recipe.name)
        categoryView.configure(titleText: "Category", valueText: recipe.category.rawValue)
        servingView.configure(titleText: "Serving", valueText: recipe.serving)
        
        prepTiemView.configure(titleText: "Prep time", valueText: "\(recipe.perpTimeHours)h \(recipe.perpTimeMinutes)min")
        spicyView.configure(titleText: "Spicy", valueText: recipe.spicy.rawValue)
        difficultyView.configure(titleText: "Difficulty", valueText: recipe.difficulty.rawValue)
    }
}

// MARK: - Navigation bar

extension RecipeDetailsVC {
    func setupNavigationBarButtons() {
        navigationItem.setRightBarButtonItems([trashNavItem, pencilNavItem, bookmarkNavItem, basketNavItem], animated: true)
        trashNavItem.tintColor = .red
    }
    
    @objc func basketButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.addIngredientsToShopingList()
    }

    @objc func bookmarkButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.toggleFavouriteStatus()
    }
    
    @objc func pencilButtonTapped(_ sender: UIBarButtonItem) {
        coordinator.navigateToRecipeEditor()
    }

    @objc func trashButtonTapped(_ sender: UIBarButtonItem) {
        viewModel.deleteRecipe()
        coordinator.dismissVC()
    }
}

// MARK: Delegate methods

extension RecipeDetailsVC: RecipeDetailsVMDelegate {
    func isFavouriteValueChanged(to: Bool) {
        switch to {
        case true:
            bookmarkNavItem.image = UIImage(systemName: bookmarkIconFilled)
        case false:
            bookmarkNavItem.image = UIImage(systemName: bookmarkIconEmpty)
        }
    }
}
