//
//  MainRouter.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import Foundation
import UIKit

protocol AppRouterProtocol {
    func setup()
}

class AppRouter: UITabBarController, AppRouterProtocol {
    private var window: UIWindow?

    // Modules
    let recipesListModule = RecipesListRouter.createModule(view: RecipesListVC())
    let shopingListModule = ShopingListRouter.createModule(view: ShopingListVC())

    init(window: UIWindow?) {
        self.window = window
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        let recipesListNavController = UINavigationController(rootViewController: recipesListModule)
        let shopingListNavController = UINavigationController(rootViewController: shopingListModule)

        
        recipesListNavController.tabBarItem = UITabBarItem(title: "Recipes", image: UIImage(systemName: "book"), selectedImage: UIImage(systemName: "book.fill"))
        shopingListNavController.tabBarItem = UITabBarItem(title: "Shopping List", image: UIImage(systemName: "basket"), selectedImage: UIImage(systemName: "basket.fill"))
        
        recipesListModule.title = "Recipes"
        shopingListModule.title = "Shoping list"
        
        viewControllers = [recipesListNavController, shopingListNavController]

        tabBar.isTranslucent = false
        tabBar.tintColor = .orange

        let appearance = UITabBarAppearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        window?.rootViewController = self
        window?.makeKeyAndVisible()
    }
}
