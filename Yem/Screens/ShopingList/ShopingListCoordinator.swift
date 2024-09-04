//
//  ShopingListCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//

import LifetimeTracker
import UIKit

extension ShopingListCoordinator {
    enum ShopingListRoute {
        case addItemSheet
    }

    enum ShopingListAlertType {
        case clearList
    }

    typealias Route = ShopingListRoute
    typealias AlertType = ShopingListAlertType
}

final class ShopingListCoordinator: Destination {
    private weak var parentCoordinator: TabBarCoordinator?

    var tabNavigator: Navigator?

    private let repository: DataRepositoryProtocol
    private let viewModel: ShopingListVM

    init(
        parentCoordinator: TabBarCoordinator? = nil,
        repository: DataRepositoryProtocol
    ) {
        self.parentCoordinator = parentCoordinator
        self.repository = repository
        self.viewModel = ShopingListVM(repository: repository)

        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func render() -> UIViewController {
        let shopingListController = ShopingListVC(coordinator: self, viewModel: viewModel)
        shopingListController.destination = self
        return shopingListController
    }

    func navigateTo(_ route: ShopingListRoute) {
        switch route {
        case .addItemSheet:
            let viewModel = ShopingListAddItemSheetVM(repository: repository)
            navigator?.presentSheet(
                ShopingListAddItemSheetVC(
                    viewModel: viewModel,
                    coordinator: self
                )
            )
        }
    }

    func presentAlert(_ type: AlertType,
                       title: String,
                       message: String,
                       confirmAction: @escaping () -> Void,
                       cancelAction: @escaping () -> Void
    ) {
        switch type {
        case .clearList:
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

    func dismissSheet() {
        navigator?.dismissSheet()
    }

    func dismissAlert() {
        navigator?.dismissAlert()
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension ShopingListCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
