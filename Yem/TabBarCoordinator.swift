////
////  MainCoordinator.swift
////  Yem
////
////  Created by Adam Zapiór on 02/01/2024.
////

import FirebaseAuth
import LifetimeTracker
import UIKit

class TabBarDestination: Destination {
    let currentUser: UserModel
    let dataRepository: DataRepository
    let authManager: AuthenticationManager

    override func render() -> UIViewController {
        // to ukrywa TABBAR z UINAVIGATIONCONTROLLERA, który jest nu samej góry na stosie aplikacji jak tworze go w init w Navigatorze
//        navigator?.setNavigationBarHidden()
        return TabBarCoordinator(currentUser: currentUser, dataRepository: dataRepository, authManager: authManager)
    }

    init(currentUser: UserModel, dataRepository: DataRepository, authManager: AuthenticationManager) {
        self.currentUser = currentUser
        self.dataRepository = dataRepository
        self.authManager = authManager
    }
}

class TabCoordinator: Destination {
    var rootViewController: UINavigationController
    var childDestination: Destination

    init(childDestination: Destination) {
        self.childDestination = childDestination
        self.rootViewController = UINavigationController(rootViewController: childDestination.render())
        super.init()
    }

    override func render() -> UIViewController {
        return rootViewController
    }

    func attach(tabBar: UITabBarController) {
        tabBar.viewControllers?.append(rootViewController)
    }
}

final class TabBarCoordinator: UITabBarController {
    var childCoordinators: [Coordinator] = []

    let dataRepository: DataRepository
    let authManager: AuthenticationManager

    lazy var recipesListCoordinator = RecipesListCoordinator(parentCoordinator: self, repository: dataRepository, viewModel: RecipesListVM(repository: dataRepository), authManager: authManager)
    lazy var shopingListCoordinator = ShopingListCoordinator(parentCoordinator: self, repository: dataRepository, viewModel: ShopingListVM(repository: dataRepository))

    init(currentUser: UserModel, dataRepository: DataRepository, authManager: AuthenticationManager) {
        self.dataRepository = dataRepository
        self.authManager = authManager

        super.init(nibName: nil, bundle: nil)
#if DEBUG
        trackLifetime()
#endif
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let recipesTabCoordinator = TabCoordinator(childDestination: recipesListCoordinator)
        let shoppingTabCoordinator = TabCoordinator(childDestination: shopingListCoordinator)

        viewControllers = [recipesTabCoordinator.render(), shoppingTabCoordinator.render()]

//        recipesListCoordinator.attatch(tabBar: self)
//        shopingListCoordinator.attatch(tabBar: self)
//
//        // To umieszcza UINavigationController z funkcji render w nowe UInavigationControllery i wtedy NavigationBar się pokazuje XD
//        let recipesNavController = UINavigationController(rootViewController: recipesListCoordinator.render())
//        let shoppingNavController = UINavigationController(rootViewController: shopingListCoordinator.render())
//
//        viewControllers = [recipesNavController, shoppingNavController]
    }
}

#if DEBUG
extension TabBarCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
