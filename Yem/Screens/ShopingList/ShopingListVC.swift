//
//  ShopingListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import UIKit

class ShopingListVC: UIViewController {
    var coordinator: ShopingListCoordinator?

    let viewModel = ShopingListVM()

    init(coordinator: ShopingListCoordinator) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = coordinator
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        print("shoping list vc did load")
    }

    func showShopingList() {}
}
