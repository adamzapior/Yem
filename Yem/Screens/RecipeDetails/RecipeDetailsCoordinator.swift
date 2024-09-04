//
//  RecipeDetailsCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import LifetimeTracker
import UIKit

final class RecipeDetailsCoordinator: Destination {
    weak var parentCoordinator: Destination?

    private var recipe: RecipeModel
    private var repository: DataRepositoryProtocol
    private let localFileManager: LocalFileManagerProtocol
    private let imageFetcherManager: ImageFetcherManagerProtocol
    private let viewModel: RecipeDetailsVM

    init(
        recipe: RecipeModel,
        repository: DataRepository,
        localFileManager: LocalFileManagerProtocol,
        imageFetcherManager: ImageFetcherManagerProtocol
    ) {
        self.recipe = recipe
        self.repository = repository
        self.localFileManager = localFileManager
        self.imageFetcherManager = imageFetcherManager
        self.viewModel = RecipeDetailsVM(
            recipe: recipe,
            repository: repository,
            localFileManager: localFileManager,
            imageFetcher: imageFetcherManager
        )

        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    override func render() -> UIViewController {
        let controller = RecipeDetailsVC(viewModel: viewModel, coordinator: self)
        controller.destination = self
        controller.hidesBottomBarWhenPushed = true
        return controller
    }

    func navigateTo(_ route: Route) {
        switch route {
        case .cookingMode:
            let viewModel = CookingModeViewModel(
                recipe: recipe,
                repository: repository
            )
            let coordinator = CookingModeCoordinator(
                viewModel: viewModel,
                recipe: recipe
            )
            coordinator.parentCoordinator = self
            navigator?.presentDestination(coordinator)
        case .recipeEditor:
            let coordinator = ManageRecipeCoordinator(
                repository: repository,
                localFileManager: localFileManager,
                imageFetcherManager: imageFetcherManager,
                recipe: recipe
            )

            coordinator.parentCoordinator = self
            navigator?.presentDestination(coordinator)
        }
    }

    func presentAlert(
        _ type: AlertType,

        title: String,
        message: String,

        confirmAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) {
        switch type {
        case .addIngredientsToShopingList, .addToFavourites, .deleteRecipe:
            let alertVC = DualOptionAlertVC(title: title, message: message) {
                confirmAction()
            } cancelAction: {
                cancelAction()
            }
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigator?.presentAlert(alertVC)
        }
    }

    func pop() {
        navigator?.pop()
    }

    func popUpToRoot() {
        navigator?.pop()
    }

    func dismissSheet() {
        navigator?.dismissSheet()
    }

    func dismissAlert() {
        navigator?.dismissAlert()
    }
}

// MARK: Helpers

extension RecipeDetailsCoordinator {
    enum Route {
        case cookingMode
        case recipeEditor
    }

    enum AlertType {
        case addIngredientsToShopingList
        case addToFavourites
        case deleteRecipe
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension RecipeDetailsCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
