//
//  AddRecipeCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

extension AddRecipeCoordinator {
    enum AddRecipeRoute {
        case ingredientsList
        case addIngredient
        case instructions
        case addInstruction
    }

    enum AddRecipeAlertType {
        case permissionAlert
        case validationAlert
    }

    typealias Route = AddRecipeRoute
    typealias AlertType = AddRecipeAlertType
}

final class AddRecipeCoordinator: Destination {
    weak var parentCoordinator: Destination?

    private let repository: DataRepositoryProtocol
    private let localFleManager: LocalFileManagerProtocol
    private let imageFetcherManager: ImageFetcherManagerProtocol
    private let recipe: RecipeModel?
    private let viewModel: AddRecipeViewModel

    init(
        repository: DataRepositoryProtocol,
        localFileManager: LocalFileManagerProtocol,
        imageFetcherManager: ImageFetcherManagerProtocol,
        recipe: RecipeModel? = nil
    ) {
        self.repository = repository
        self.localFleManager = localFileManager
        self.imageFetcherManager = imageFetcherManager
        self.recipe = recipe
        self.viewModel = AddRecipeViewModel(
            repository: repository,
            localFileManager: localFileManager,
            imageFetcherManager: imageFetcherManager,
            existingRecipe: recipe
        )
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    override func render() -> UIViewController {
        let addRecipeVC = AddRecipeVC(coordinator: self, viewModel: viewModel)
        addRecipeVC.destination = self
        addRecipeVC.hidesBottomBarWhenPushed = true
        return addRecipeVC
    }

    func navigateTo(_ route: Route) {
        let viewModel = viewModel
        switch route {
        case .ingredientsList:
            let controller = AddRecipeIngredientsVC(viewModel: viewModel, coordinator: self)
            navigator?.presentScreen(controller)
        case .addIngredient:
            let controller = AddIngredientSheetVC(viewModel: viewModel, coordinator: self)
            navigator?.presentSheet(controller)

        case .instructions:
            let controller = AddRecipeInstructionsVC(viewModel: viewModel, coordinator: self)
            navigator?.presentScreen(controller)

        case .addInstruction:
            let controller = AddInstructionSheetVC(viewModel: viewModel, coordinator: self)
            navigator?.presentSheet(controller)
        }
    }

    func presentAlert(_ alertType: AlertType, title: String, message: String, resourceName: String? = nil) {
        switch alertType {
        case .permissionAlert:
            let alertVC = DualOptionAlertVC(title: title, message: message) {
                self.navigator?.presentSystemSettings()
                self.dismissAlert()
            } cancelAction: {
                self.dismissAlert()
            }

            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigator?.presentAlert(alertVC)
        case .validationAlert:
            let alertVC = ValidationAlertVC(title: title, message: message)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigator?.presentAlert(alertVC)
        }
    }

    func pop() {
        navigator?.pop()
    }

    func dismissAlert() {
        navigator?.dismissAlert()
    }

    func dismissSheet() {
        navigator?.dismissSheet()
    }

    func popUptoRoot() {
        navigator?.popUpToRoot()
    }
}

#if DEBUG
extension AddRecipeCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
