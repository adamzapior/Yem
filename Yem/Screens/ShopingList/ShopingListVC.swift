//
//  ShopingListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import UIKit

class ShopingListVC: UIViewController {
    var coordinator: ShopingListCoordinator?
    let repository: DataRepository

    let viewModel: ShopingListVM

    init(coordinator: ShopingListCoordinator, repository: DataRepository, viewModel: ShopingListVM) {
        self.coordinator = coordinator
        self.repository = repository
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
