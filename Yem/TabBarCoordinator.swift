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
    var childCoordinators: [Coordinator] = []
    weak var coordinator: AppCoordinator?
    
    let repository: DataRepository = .init()

    let navig = UINavigationController()
    
    lazy var recipesListCoordinator = RecipesListCoordinator(parentCoordinator: self, repository: repository, viewModel: RecipesListVM(repository: repository), navigationController: UINavigationController())
    lazy var shopingListCoordinator = ShopingListCoordinator(parentCoordinator: self, repository: repository, viewModel: ShopingListVM(repository: repository), navigationController: UINavigationController())
    
    init(currentUser: User, coordinator: AppCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        
        recipesListCoordinator.parentCoordinator = self
        shopingListCoordinator.parentCoordinator = self
        
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
        
        for item in [recipesListCoordinator, shopingListCoordinator] {
            coordinator?.addChildCoordinator(item as? Coordinator)
        }
        
        recipesListCoordinator.start(animated: false)
        shopingListCoordinator.start(animated: false)
        
        viewControllers = [
            recipesListCoordinator.navigationController,
            shopingListCoordinator.navigationController
        ]
    }
}

#if DEBUG
extension TabBarCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
