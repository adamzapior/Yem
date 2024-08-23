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

//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(appDidEnterBackground),
//            name: UIApplication.didEnterBackgroundNotification,
//            object: nil
//        )
//
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(appWillEnterForeground),
//            name: UIApplication.willEnterForegroundNotification,
//            object: nil
//        )

#if DEBUG
        trackLifetime()
#endif
    }

    deinit {
        UIApplication.shared.isIdleTimerDisabled = false

//        NotificationCenter.default.removeObserver(self)
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

//    // MARK: - App Lifecycle Handlers
//
//    @objc private func appDidEnterBackground() {
//        // Kod do wykonania, gdy aplikacja wchodzi w tło
//        viewModel.saveTimerState() // Możesz zapisać stan aplikacji
//    }
//
//    @objc private func appWillEnterForeground() {
//        // Kod do wykonania, gdy aplikacja wraca na pierwszy plan
//        viewModel.restoreTimerState() // Możesz przywrócić stan aplikacji
//    }
}

#if DEBUG
extension CookingModeCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
