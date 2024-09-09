//
//  IngredientsListSheetVC.swift
//  Yem
//
//  Created by Adam Zapiór on 18/08/2024.
//

import Combine
import Foundation
import LifetimeTracker
import UIKit

final class CookingIngredientsListSheetVC: UIViewController {
    weak var coordinator: CookingModeCoordinator?
    private let viewModel: CookingModeViewModel

    private let tableView = UITableView()
    private let emptyTableLabel = TextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.secondaryText)

    private var cancellables = Set<AnyCancellable>()

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

        setupTableView()
        setupSheet()

        observeViewModelOutput()
    }

    // MARK: - Setup UI

    private func setupSheet() {
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
            presentationController.prefersGrabberVisible = true
        }
    }

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

// MARK: - Observed ViewModel Output & UI actions

extension CookingIngredientsListSheetVC {
    private func observeViewModelOutput() {
        viewModel.outputCookingIngredientsListSheetEventPublisher
            .sink { [weak self] event in
                self?.handleViewModelOutput(event)
            }
            .store(in: &cancellables)
    }
}

// MARK: - Handle Output & UI Actions

extension CookingIngredientsListSheetVC {
    private func handleViewModelOutput(_ event: CookingModeViewModel.CookingIngredientsListSheetOutput) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch event {
            case .timerStopped:
                presentTimerFinishedAlert()
            case .reloadIngredientTable:
                tableView.reloadData()
            }
        }
    }
}

// MARK: -  UITableViewDataSource

extension CookingIngredientsListSheetVC: UITableViewDataSource {
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

        let sectionType = ShopingListType.allCases[indexPath.section]
        let model: ShopingListModel
        switch sectionType {
        case .unchecked:
            model = viewModel.uncheckedList[indexPath.row]
            cell.configure(with: model, type: .unchecked, backgroundColor: .secondaryContainer)

        case .checked:
            model = viewModel.checkedList[indexPath.row]
            cell.configure(with: model, type: .checked, backgroundColor: .secondaryContainer)
        }

        cell.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                DispatchQueue.main.async { [weak self] in
                    self?.handleCellEvent(event: event, indexPath: indexPath)
                }
            }
            .store(in: &cell.cancellables)

        return cell
    }

    // MARK: Cell Event

    func handleCellEvent(event: ShopingListCellEvent, indexPath: IndexPath) {
        guard let sectionType = ShopingListType(rawValue: indexPath.section) else { return }

        var ingredient: ShopingListModel
        switch sectionType {
        case .unchecked:
            ingredient = viewModel.uncheckedList[indexPath.row]
        case .checked:
            ingredient = viewModel.checkedList[indexPath.row]
        }
        viewModel.updateIngredientCheckStatus(ingredient: &ingredient)
    }
}

// MARK: -  UITableViewDelegate

extension CookingIngredientsListSheetVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Navigation

extension CookingIngredientsListSheetVC {
    private func presentTimerFinishedAlert() {
        let title = "Your timer has ended!"
        let message = "⏰⏰⏰"

        coordinator?.presentAlert(.timerFinished, title: title, message: message)
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension CookingIngredientsListSheetVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
