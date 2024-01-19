//
//  MainCoordinator.swift
//  Yem
//
//  Created by Adam Zapiór on 02/01/2024.
//
import UIKit

enum AppFlow { // Mark 1
    case RecipesList
    case ShopingList
}

protocol MainBaseCoordinator: Coordinator {
    var recipesListCoordinator: RecipesListCoordinator { get }
    var shopingListCoordinator: ShopingListCoordinator { get }
    func moveTo(flow: AppFlow)
    func handleDeepLink(text: String)
}

protocol RecipesListCoordinated {
    var coordinator: RecipesListCoordinator? { get }
}

protocol ShopingListCoordinated {
    var coordinator: ShopingListCoordinator? { get }
}

protocol FlowCoordinator: AnyObject {
    var parentCoordinator: MainBaseCoordinator? { get set }
}

protocol Coordinator: FlowCoordinator {
    var rootViewController: UIViewController { get set }
    func start() -> UIViewController
    @discardableResult func resetToRoot() -> Self
}

extension Coordinator {
    var navigationRootViewController: UINavigationController? {
        (rootViewController as? UINavigationController)
    }
    
    func resetToRoot() -> Self {
        navigationRootViewController?.popToRootViewController(animated: false)
        return self
    }
}
  
class MainCoordinator: MainBaseCoordinator {
    var parentCoordinator: MainBaseCoordinator? // Mark 3
    
//    let moc = CoreDataManager()
    lazy var repository = DataRepository()
    
    lazy var recipesListCoordinator: RecipesListCoordinator = .init(repository: repository, viewModel: RecipesListVM(repository: repository))
    lazy var shopingListCoordinator: ShopingListCoordinator = .init(repository: repository, viewModel: ShopingListVM(repository: repository))
    
    lazy var rootViewController: UIViewController = UITabBarController()
    
    func start() -> UIViewController {
        if let tabBarController = rootViewController as? UITabBarController {
            // Set selected item color
            tabBarController.tabBar.tintColor = UIColor.ui.theme
        }
        
        let recipesListController = recipesListCoordinator.start()
        recipesListCoordinator.parentCoordinator = self
        recipesListController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "book"), tag: 0)
        
        let shopingListController = shopingListCoordinator.start()
        shopingListCoordinator.parentCoordinator = self
        shopingListController.tabBarItem = UITabBarItem(title: "Orders", image: UIImage(systemName: "basket"), tag: 1)
        
        (rootViewController as? UITabBarController)?.viewControllers = [recipesListController, shopingListController]
      
        return rootViewController
    }
    
    func moveTo(flow: AppFlow) {
        switch flow {
        case .RecipesList:
            (rootViewController as? UITabBarController)?.selectedIndex = 0
        case .ShopingList:
            (rootViewController as? UITabBarController)?.selectedIndex = 1
        }
    }
    
    func handleDeepLink(text: String) {
//            deepLinkCoordinator.handleDeeplink(deepLink: text)
    }
    
    func resetToRoot() -> Self {
        moveTo(flow: .RecipesList)
        return self
    }
}
