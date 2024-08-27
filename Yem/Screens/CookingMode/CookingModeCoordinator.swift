//
//  CookingModeCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 17/08/2024.
//

import LifetimeTracker
import UIKit

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

    func openIngredientsSheet() {
        let controller = CookingIngredientsListSheetVC(
            coordinator: self,
            viewModel: viewModel
        )
        navigator?.presentSheet(controller)
    }

    func openTimeSheet() {
        let controller = CookingTimerSheetVC(
            coordinator: self,
            viewModel: viewModel
        )
        navigator?.presentSheet(controller)
    }

    func dismissSheet() {
        navigator?.dismissSheet()
    }

    func dismissAlert() {
        navigator?.dismissAlert()
    }

    // MARK: Alerts

    func presentExitAlert() {
        let title = "Are your sure?"
        let message = "Your progress and timer will not be saved."

        let alertVC = DualOptionAlertVC(title: title, message: message) {
            self.navigator?.pop()
            self.dismissAlert()
        } cancelAction: {
            self.dismissAlert()
        }

        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigator?.presentAlert(alertVC)
    }

    func presentTimerStoppedAlert() {
        let alertVC = ValidationAlertVC(title: "Your timer has ended!",
                                        message: "⏰⏰⏰",
                                        dismissCompletion: {
                                            self.viewModel.stopVibration()
                                        })

        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        navigator?.presentAlert(alertVC)
    }
}

#if DEBUG
extension CookingModeCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
