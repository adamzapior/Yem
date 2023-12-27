//
//  TabBarVC.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Foundation
import UIKit

class TabBarVC: UITabBarController {
        
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        let vc1 = UINavigationController(rootViewController: RecipesListVC())
        let vc2 = UINavigationController(rootViewController: ShopingListVC())

        vc1.tabBarItem.image = UIImage(systemName:
            "book")
        vc2.tabBarItem.image = UIImage(systemName: "basket")

        vc1.title = "Recipes"
        vc2.title = "Shoping list"

        tabBar.isTranslucent = false
        tabBar.tintColor = .orange

        let appearance = UITabBarAppearance()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        setViewControllers([vc1, vc2], animated: true)
                
//        let appearanceBar = UINavigationBarAppearance()
//        appearanceBar.configureWithOpaqueBackground()
////        appearanceBar.backgroundColor = .clear // Ustaw tło paska nawigacyjnego, jeśli potrzebujesz
//        appearanceBar.titleTextAttributes = [.foregroundColor: UIColor.ui.theme] // Kolor tytułu
//        appearanceBar.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.ui.theme] // Kolor tekstu przycisku powrotu
//        appearanceBar.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.ui.theme]
//        
        UINavigationBar.appearance().tintColor = .ui.theme
        
//            UINavigationBar.appearance().standardAppearance = appearanceBar
//            UINavigationBar.appearance().compactAppearance = appearanceBar // Dla mniejszych pasków nawigacyjnych, jeśli istnieją
//            UINavigationBar.appearance().scrollEdgeAppearance = appearanceBar // Dla pasków nawigacyjnych na 'edge' ekranu, jak w przypadku dużych tytułów
    }
}
