//
//  AddRecipeCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

final class AddRecipeCoordinator: Destination, Coordinator {
    let viewModel: AddRecipeViewModel
    weak var parentCoordinator: Destination?

    init(viewModel: AddRecipeViewModel) {
        self.viewModel = viewModel
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

    func navigateTo(_ route: AddRecipeRoute) {
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

    func showSettingsAlert(for resource: String) {
        let title = "Access to \(resource) is required"
        let message = "Please enable access to the \(resource) in Settings."
        
        let alertVC = DualOptionAlertVC(title: title, message: message) {
            self.navigator?.presentSystemSettings()
            self.dismissAlert()
        } cancelAction: {
            self.dismissAlert()
        }
        
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigator?.presentAlert(alertVC)
    }
    

    func presentValidationAlert(title: String, message: String) {
        let alertVC = ValidationAlertVC(title: title, message: message)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigator?.presentAlert(alertVC)
    }
    
    func dismissAlert() {
        navigator?.dismissAlert()
    }

    func dismissSheet() {
        navigator?.dismissSheet()
    }

    func dismissVCStack() {
        navigator?.popUpToRoot()
    }
}

enum AddRecipeRoute {
    case ingredientsList
    case addIngredient
    case instructions
    case addInstruction
}

#if DEBUG
extension AddRecipeCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
