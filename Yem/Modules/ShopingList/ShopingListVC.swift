//
//  ShopingListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import UIKit

class ShopingListVC: UIViewController, ShopingListViewProtocol {
    
    var presenter: ShopingListPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("shoping list vc did load")
    }
    
    func showShopingList() {
        //
    }

}
