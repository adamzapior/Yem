//
//  ShopingListRouter.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import Foundation
import UIKit

class ShopingListRouter: ShopingListRouterProtocol {
    static func createModule(view: ShopingListVC) -> UIViewController {
        let presenter: ShopingListPresenterProtocol & ShopingListOutputInteractorProtocol = ShopingListPresenter()
        
        view.presenter = presenter
        view.presenter?.router = ShopingListRouter()
        view.presenter?.view = view
        view.presenter?.interactor = ShopingListInteractor()
        view.presenter?.interactor?.presenter = presenter
        
        return view
    }
    
    
}
