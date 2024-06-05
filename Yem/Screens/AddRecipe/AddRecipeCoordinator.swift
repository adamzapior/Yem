//
//  AddRecipeCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

final class AddRecipeCoordinator: Destination {
    var viewModel: AddRecipeViewModel

    init(viewModel: AddRecipeViewModel) {
        self.viewModel = viewModel
        super.init()

#if DEBUG
        trackLifetime()
#endif
    }

    override func render() -> UIViewController {
        print("Rendering AddRecipeVC")
        let addRecipeVC = AddRecipeVC(coordinator: self, viewModel: viewModel)
        return addRecipeVC
    }

    func pushVC(for route: AddRecipeRoute) {
        let viewModel = viewModel
        switch route {
        case .ingredientsList:
            let controller = AddRecipeIngredientsVC(viewModel: viewModel, coordinator: self)
            navigator?.presentScreen(controller)
//            navigationController.pushViewController(controller, animated: true)
        case .addIngredient:
            let controller = AddIngredientSheetVC(viewModel: viewModel, coordinator: self)
            navigator?.presentScreen(controller)

//            navigationController.present(controller, animated: true)
        case .instructions:
            let controller = AddRecipeInstructionsVC(viewModel: viewModel, coordinator: self)
//            navigationController.pushViewController(controller, animated: true)
            navigator?.presentScreen(controller)

        case .addInstruction:
            let controller = AddInstructionSheetVC(viewModel: viewModel, coordinator: self)
            navigator?.presentScreen(controller)

//            navigationController.present(controller, animated: true)
        }
    }

    func presentValidationAlert(title: String, message: String) {
        let alertVC = ValidationAlertVC(title: title, message: message)
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigator?.present(alert: alertVC)
//        navigationController.present(alertVC, animated: true, completion: nil)
    }

//
    func dismissVC() {
        navigator?.dismissAlert()
//        navigationController.dismiss(animated: true)
    }

    func dismissVCStack() {
        navigator?.pop()
//        navigationController.popToRootViewController(animated: true)
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
