//
//  RecipesListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

extension RecipesListCoordinator {
    enum RecipesListRoute {
        case addRecipeScreen
        case recipeDetailsScreen
        case settingsScreen
    }

    typealias Route = RecipesListRoute
}

final class RecipesListCoordinator: Destination {
    private let authManager: AuthenticationManager
    private let repository: DataRepository
    private let localFileManager: LocalFileManagerProtocol
    private let imageFetcherManager: ImageFetcherManagerProtocol

    lazy var viewModel = RecipesListVM(
        repository: repository,
        localFileManager: localFileManager,
        imageFetcherManager: imageFetcherManager
    )

    init(
        repository: DataRepository,
        authManager: AuthenticationManager,
        localFileManager: LocalFileManagerProtocol,
        imageFetcherManager: ImageFetcherManagerProtocol
    ) {
        self.repository = repository
        self.authManager = authManager
        self.localFileManager = localFileManager
        self.imageFetcherManager = imageFetcherManager

        print("DEBUG: RecipesListCoordinator - init")
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    deinit {
        print("DEBUG: RecipesListCoordinator - deinit")
    }

    override func render() -> UIViewController {
        let controller = RecipesListVC(coordinator: self, viewModel: viewModel)
        controller.destination = self
        return controller
    }

    func navigateTo(_ route: Route, recipe: RecipeModel? = nil) {
        switch route {
        case .addRecipeScreen:
            let coordinator = ManageRecipeCoordinator(
                repository: repository,
                localFileManager: localFileManager,
                imageFetcherManager: imageFetcherManager
            )

            coordinator.parentCoordinator = self
            navigator?.presentDestination(coordinator)
        case .recipeDetailsScreen:
            guard let recipe = recipe else { return }
            let coordinator = RecipeDetailsCoordinator(
                recipe: recipe,
                repository: repository,
                localFileManager: localFileManager,
                imageFetcherManager: imageFetcherManager
            )

            coordinator.parentCoordinator = self
            navigator?.presentDestination(coordinator)
        case .settingsScreen:
            let coordinator = SettingsCoordinator(authManager: authManager)

            coordinator.parentCoordinator = self
            navigator?.presentDestination(coordinator)
        }
    }
}

// MARK: - LifetimeTracker


#if DEBUG
extension RecipesListCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
