//
//  CookingModeCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 17/08/2024.
//

import LifetimeTracker
import UIKit

extension CookingModeCoordinator {
    enum CookingModeRoute {
        case ingredientSheet
        case timerSheet
    }

    enum CookingModeAlertType {
        case exitScreen
        case timerFinished
    }

    typealias Route = CookingModeRoute
    typealias AlertType = CookingModeAlertType
}

final class CookingModeCoordinator: Destination {
    weak var parentCoordinator: Destination?
    let viewModel: CookingModeViewModel
    let recipe: RecipeModel

    private var isTimerActive: Bool = false

    init(viewModel: CookingModeViewModel, recipe: RecipeModel) {
        self.viewModel = viewModel
        self.recipe = recipe
        super.init()

        UIApplication.shared.isIdleTimerDisabled = true

#if DEBUG
        trackLifetime()
#endif
    }

    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }

    override func render() -> UIViewController {
        let controller = CookingModeViewController(
            viewModel: viewModel,
            coordinator: self,
            recipe: recipe
        )
        controller.destination = self
        controller.hidesBottomBarWhenPushed = true
        return controller
    }

    func navigateTo(_ route: Route) {
        switch route {
        case .ingredientSheet:
            let controller = CookingIngredientsListSheetVC(
                coordinator: self,
                viewModel: viewModel
            )
            navigator?.presentSheet(controller)
        case .timerSheet:
            let controller = CookingTimerSheetVC(
                coordinator: self,
                viewModel: viewModel
            )
            navigator?.presentSheet(controller)
        }
    }

    func presentAlert(_ type: AlertType, title: String, message: String) {
        switch type {
        case .exitScreen:
            let alertVC = DualOptionAlertVC(title: title, message: message) {
                self.navigator?.pop()
                self.dismissAlert()
            } cancelAction: {
                self.dismissAlert()
            }
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigator?.presentAlert(alertVC)
        case .timerFinished:
            let alertVC = ValidationAlertVC(title: title,
                                            message: message,
                                            dismissCompletion: {
                                                self.viewModel.stopVibration()
                                            })
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            navigator?.presentAlert(alertVC)
        }
    }
    
    func pop() {
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
extension CookingModeCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
