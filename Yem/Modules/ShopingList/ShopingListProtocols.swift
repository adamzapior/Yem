//
//  ShopingLsitProtocols.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import Foundation
import UIKit

protocol ShopingListViewProtocol: AnyObject {
    // presenter -? view
    var presenter: ShopingListPresenterProtocol? { get set }
    func showShopingList()
}

// presenter: view -> presenter
protocol ShopingListPresenterProtocol {
    var interactor: ShopingListInputInteractorProtocol? { get set }
    var view: ShopingListViewProtocol? { get set }
    var router: ShopingListRouterProtocol? { get set }
    
    func viewDidLoad()
}

protocol ShopingListInputInteractorProtocol {
    var presenter: ShopingListOutputInteractorProtocol? { get set }
    
    // presenter -> interactor
    func getShopingList()
}


protocol ShopingListOutputInteractorProtocol {
    // interactor -> presenter
    func shopingListDidFetch()
}

// presenter -> router
protocol ShopingListRouterProtocol {
    static func createModule(view: ShopingListVC) -> UIViewController
}

