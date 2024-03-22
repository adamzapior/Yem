//
//  ShopingListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import UIKit

final class ShopingListVC: UIViewController {
    private let coordinator: ShopingListCoordinator?
    private let viewModel: ShopingListVM

    private let tableView = UITableView()
    private let emptyTableLabel = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.secondaryText)

    private lazy var trashNavItem = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(trashButtonTapped))

    init(coordinator: ShopingListCoordinator, viewModel: ShopingListVM) {
        self.coordinator = coordinator
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
        title = "Shoping list"

        viewModel.delegate = self

        setupNavigationBarButtons()
        setupTableView()
        setupEmptyTableLabel()

        Task {
            viewModel.loadShopingList()
        }
    }

    // MARK: - Setup UI

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ShopingListCell.self, forCellReuseIdentifier: ShopingListCell.id)

        tableView.backgroundColor = UIColor.ui.background
        tableView.showsVerticalScrollIndicator = false
        tableView.allowsSelection = false
        tableView.separatorStyle = .none

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupEmptyTableLabel() {
        view.addSubview(emptyTableLabel)
        emptyTableLabel.text = "Your shopping list is empty"

        emptyTableLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

// MARK: -  TableView delegate & data source

extension ShopingListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ShopingListType.allCases.count
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = ShopingListType.allCases[section]
        switch section {
        case .unchecked:
            return viewModel.uncheckedList.isEmpty ? nil : "To buy"
        case .checked:
            return viewModel.checkedList.isEmpty ? nil : "Bought"
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = ShopingListType.allCases[section]
        switch section {
        case .unchecked:
            return viewModel.uncheckedList.count
        case .checked:
            return viewModel.checkedList.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShopingListCell.id, for: indexPath) as? ShopingListCell else {
            fatalError("ShopingListCell error")
        }

        let section = ShopingListType.allCases[indexPath.section]
        switch section {
        case .unchecked:
            cell.configure(with: viewModel.uncheckedList[indexPath.row], type: .unchecked)
        case .checked:
            cell.configure(with: viewModel.checkedList[indexPath.row], type: .checked)
        }

        cell.delegate = self

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: -  TableViewCell delegate

extension ShopingListVC: ShopingListCellDelegate {
    func didTapButton(in cell: ShopingListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        var ingredient: ShopingListModel
        switch indexPath.section {
        case ShopingListType.unchecked.rawValue:
            ingredient = viewModel.uncheckedList[indexPath.row]
        case ShopingListType.checked.rawValue:
            ingredient = viewModel.checkedList[indexPath.row]
        default:
            return
        }

        viewModel.updateIngredientCheckStatus(ingredient: &ingredient)
    }
}

// MARK: ViewModel delegate

extension ShopingListVC: ShopingListVMDelegate {
    func reloadTable() {
        tableView.reloadData()
        
        if viewModel.uncheckedList.isEmpty && viewModel.checkedList.isEmpty {
            emptyTableLabel.isHidden = false
        } else {
            emptyTableLabel.isHidden = true
        }
    }
}

// MARK: - Navigation bar

extension ShopingListVC {
    func setupNavigationBarButtons() {
        navigationItem.setRightBarButtonItems([trashNavItem], animated: true)
        trashNavItem.tintColor = .red
    }

    @objc func trashButtonTapped(_ sender: UIBarButtonItem) {
        coordinator?.presentClearShopingListAlert()
    }
}
