//
//  ShopingListPresenter.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import Foundation

class ShopingListPresenter: ShopingListPresenterProtocol {
   
    var interactor: ShopingListInputInteractorProtocol?
    var view: ShopingListViewProtocol?
    var router: ShopingListRouterProtocol?
    
    func viewDidLoad() {
        //
    }
    
    
}

extension ShopingListPresenter: ShopingListOutputInteractorProtocol {
    func shopingListDidFetch() {
        //
    }
    
    
}
