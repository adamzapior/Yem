//
//  RecipeDetailsCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 20/02/2024.
//

import LifetimeTracker
import UIKit

extension RecipeDetailsCoordinator {
    enum RecipeDetailsRoute {
        case cookingMode
        case recipeEditor
    }

    enum RecipeDetailsAlertType {
        case addIngredientsToShopingList
        case addToFavourites
        case deleteRecipe
    }

    typealias Route = RecipeDetailsRoute
    typealias AlertType = RecipeDetailsAlertType
}

final class RecipeDetailsCoordinator: Destination {
    weak var parentCoordinator: Destination?

    private var recipe: RecipeModel
    private var repository: DataRepositoryProtocol
    private let localFileManager: LocalFileManagerProtocol
    private let imageFetcherManager: ImageFetcherManagerProtocol

    let viewModel: RecipeDetailsVM

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
            let coordinator = AddRecipeCoordinator(
                repository: repository,
                localFileManager: localFileManager,
                imageFetcherManager: imageFetcherManager,
                recipe: recipe
            )

            coordinator.parentCoordinator = self
            navigator?.presentDestination(coordinator)
        }
    }

    func presentAlert(_ type: AlertType, title: String, message: String) {
        switch type {
        case .addIngredientsToShopingList:
            let alertVC = DualOptionAlertVC(title: title, message: message) {
                self.viewModel.addIngredientsToShopingList()
                self.navigator?.dismissAlert()
            } cancelAction: {
                self.navigator?.dismissAlert()
            }
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigator?.presentAlert(alertVC)
        case .addToFavourites:
            let alertVC = DualOptionAlertVC(title: title, message: message) {
                self.viewModel.toggleFavouriteStatus()
                self.navigator?.dismissAlert()
            } cancelAction: {
                self.navigator?.dismissAlert()
            }
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigator?.presentAlert(alertVC)
        case .deleteRecipe:
            let alertVC = DualOptionAlertVC(title: title, message: message) {
                self.viewModel.deleteRecipe()
                self.navigator?.pop()
            } cancelAction: {
                self.navigator?.dismissAlert()
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

#if DEBUG
extension RecipeDetailsCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
