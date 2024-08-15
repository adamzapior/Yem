//
//  RecipesListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

final class RecipesListCoordinator: Destination {
    let authManager: AuthenticationManager
    let repository: DataRepository
    var viewModel: RecipesListVM
    let localFileManager: LocalFileManagerProtocol
    let imageFetcherManager: ImageFetcherManagerProtocol

    init(
        repository: DataRepository,
        viewModel: RecipesListVM,
        authManager: AuthenticationManager,
        localFileManager: LocalFileManagerProtocol,
        imageFetcherManager: ImageFetcherManagerProtocol
    ) {
        self.repository = repository
        self.viewModel = viewModel
        self.authManager = authManager
        self.localFileManager = localFileManager
        self.imageFetcherManager = imageFetcherManager
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    override func render() -> UIViewController {
        let controller = RecipesListVC(coordinator: self, viewModel: viewModel)
        controller.destination = self
        return controller
    }

    // MARK: Navigation

    func navigateToAddRecipeScreen() {
        let viewModel = AddRecipeViewModel(
            repository: repository,
            localFileManager: localFileManager,
            imageFetcherManager: imageFetcherManager
        )
        let coordinator = AddRecipeCoordinator(viewModel: viewModel)
        coordinator.parentCoordinator = self
        navigator?.presentDestination(coordinator)
    }

    func navigateToRecipeDetail(with recipe: RecipeModel) {
        let viewModel = RecipeDetailsVM(
            recipe: recipe,
            repository: repository,
            localFileManager: localFileManager,
            imageFetcher: imageFetcherManager
        )
        let coordinator = RecipeDetailsCoordinator(
            viewModel: viewModel,
            recipe: recipe,
            repository: repository,
            localFileManager: localFileManager,
            imageFetcherManager: imageFetcherManager
        )
        coordinator.parentCoordinator = self
        navigator?.presentDestination(coordinator)
    }

    func navigateToSettings() {
        let viewModel = SettingsViewModel(authManager: authManager)
        let coordinator = SettingsCoordinator(viewModel: viewModel)
        coordinator.parentCoordinator = self
        navigator?.presentDestination(coordinator)
    }
}

#if DEBUG
extension RecipesListCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
