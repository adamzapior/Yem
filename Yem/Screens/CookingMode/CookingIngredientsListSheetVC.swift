//
//  IngredientsListSheetVC.swift
//  Yem
//
//  Created by Adam Zapiór on 18/08/2024.
//

import Foundation
import LifetimeTracker
import UIKit

final class CookingIngredientsListSheetVC: UIViewController {
    weak var coordinator: CookingModeCoordinator?
    var viewModel: CookingModeViewModel

    private let tableView = UITableView()
    private let emptyTableLabel = TextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.secondaryText)

    init(coordinator: CookingModeCoordinator, viewModel: CookingModeViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
#if DEBUG
        trackLifetime()
#endif
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Shoping list"

        viewModel.delegateIngredientSheet = self
        setupTableView()

        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
            presentationController.prefersGrabberVisible = true
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
}

// MARK: -  TableView delegate & data source

extension CookingIngredientsListSheetVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ShopingListType.allCases.count
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = ShopingListType.allCases[section]
        switch section {
        case .unchecked:
            return viewModel.uncheckedList.isEmpty ? nil : "To use"
        case .checked:
            return viewModel.checkedList.isEmpty ? nil : "Used"
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
            cell.configure(with: viewModel.uncheckedList[indexPath.row], type: .unchecked, backgroundColor: .ui.secondaryContainer)
        case .checked:
            cell.configure(with: viewModel.checkedList[indexPath.row], type: .checked, backgroundColor: .ui.secondaryContainer)
        }

        cell.delegate = self

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: -  TableViewCell delegate

extension CookingIngredientsListSheetVC: ShopingListCellDelegate {
    func checklistTapped(in cell: ShopingListCell) {
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

extension CookingIngredientsListSheetVC: CookingIngredientsListSheetVCDelegate {
    func timerStoppedWhenIngredientSheetOpen() {
        coordinator?.presentTimerStoppedAlert()
    }

    func reloadTable() {
        tableView.reloadData()
    }
}

#if DEBUG
extension CookingIngredientsListSheetVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
