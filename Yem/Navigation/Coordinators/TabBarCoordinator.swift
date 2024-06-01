////
////  MainCoordinator.swift
////  Yem
////
////  Created by Adam Zapiór on 02/01/2024.
////

import FirebaseAuth
import LifetimeTracker
import UIKit

final class TabBarCoordinator: UITabBarController {
//    var childCoordinators: [Coordinator] = [] // 4delete
    
    weak var parentCoordinator: AppCoordinator?

    var recipesNavigator: Navigator?
    var shoppingNavigator: Navigator?

    weak var navigator: Navigator?
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

        // Inicjalizacja RecipesListCoordinator
        let recipesCoordinator = RecipesListCoordinator(parentCoordinator: self, repository: dataRepository, viewModel: RecipesListVM(repository: dataRepository), authManager: authManager)
        recipesNavigator = Navigator(rootViewController: recipesCoordinator.render())
        recipesCoordinator.navigator = recipesNavigator
//        recipesCoordinator.tabNavigator = recipesNavigator

        // Inicjalizacja innego koordynatora dla drugiego tabu
        let shoppingCoordinator = ShopingListCoordinator(parentCoordinator: self, repository: dataRepository, viewModel: ShopingListVM(repository: dataRepository))
        shoppingNavigator = Navigator(rootViewController: shoppingCoordinator.render())
        shoppingCoordinator.tabNavigator = shoppingNavigator

        // Dodanie widoków do tab bar controllera
        if let recipesNav = recipesNavigator?.navigationController, let shopingNav = shoppingNavigator?.navigationController {
            recipesNav.tabBarItem = UITabBarItem(title: "Recipes", image: UIImage(systemName: "book"), selectedImage: nil)
            shopingNav.tabBarItem = UITabBarItem(title: "Shopping", image: UIImage(systemName: "cart"), selectedImage: nil)
            viewControllers = [recipesNav, shopingNav]
        }
    }

    func clearAllNavigators() {
        // Zwolnienie kontrolerów związanych z navigatorami
        recipesNavigator?.clearAllViewControllers()
        shoppingNavigator?.clearAllViewControllers()

        // Ustawienie navigatorów na nil, aby umożliwić dealokację
        recipesNavigator = nil
        shoppingNavigator = nil
        
        print(recipesNavigator.debugDescription)
        print(shoppingNavigator.debugDescription)
        print("IS THAT WORKING")

    }

    func resetToOnboarding() {
//        guard let appCoordinator = UIApplication.shared.delegate as? SceneDelegate?.appCoordinator else {
//            return
//        }
//        appCoordinator.navigateToOnboarding()
    }
    
    func resetToInitialView() {
        print("resetToInitialView from TabBarCoordinator")
        if parentCoordinator == nil {
            print("PARENT IS NIL")
        }
        parentCoordinator?.resetToInitialView()
    }
}

#if DEBUG
extension TabBarCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
