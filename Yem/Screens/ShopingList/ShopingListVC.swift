//
//  ShopingListVC.swift
//  Yem
//
//  Created by Adam Zapiór on 06/12/2023.
//

import Combine
import LifetimeTracker
import UIKit

final class ShopingListVC: UIViewController {
    private weak var coordinator: ShopingListCoordinator?
    private let viewModel: ShopingListVM

    private let tableView = UITableView()
    private let emptyTableLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .ui.secondaryText,
        textAlignment: .center
    )

    private let activityIndicatorView = UIActivityIndicatorView()

    private lazy var addNavItem = UIBarButtonItem(
        image: UIImage(
            systemName: "plus"
        ),
        style: .plain,
        target: self,
        action: #selector(addItemButtonTapped)
    )
    private lazy var trashNavItem = UIBarButtonItem(
        image: UIImage(
            systemName: "trash"
        ),
        style: .plain,
        target: self,
        action: #selector(trashItemButtonTapped)
    )

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    init(coordinator: ShopingListCoordinator, viewModel: ShopingListVM) {
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

        setupNavigationBarButtons()
        setupTableView()
        setupEmptyTableLabel()
        setupActivityIndicatorView()
        setupVoiceOverAccessibility()

        observeViewModelEventOutput()
        
        viewModel.inputEvent.send(.viewDidLoad)
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
        emptyTableLabel.numberOfLines = 0

        emptyTableLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        emptyTableLabel.isHidden = true
    }

    private func setupActivityIndicatorView() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()

        activityIndicatorView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }

    private func hideActivityIndicatorView() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }

    private func setupVoiceOverAccessibility() {
        addNavItem.isAccessibilityElement = true
        addNavItem.accessibilityLabel = "Add button"
        addNavItem.accessibilityHint = "Open sheet to add new ingredient to list"

        trashNavItem.isAccessibilityElement = true
        trashNavItem.accessibilityLabel = "Delete button"
        trashNavItem.accessibilityHint = "Use this button to clear your shoping list"
    }
}

// MARK: - Observe ViewModel Output & UI actions

extension ShopingListVC {
    private func observeViewModelEventOutput() {
        viewModel.outputPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                DispatchQueue.main.async { [weak self] in
                    self?.handleViewModelOutput(event: event)
                }
            }
            .store(in: &cancellables)
        print(cancellables.count)
    }
}

// MARK: - Handle Output & UI Actions

extension ShopingListVC {
    private func handleViewModelOutput(event: ShopingListVM.Output) {
        switch event {
        case .reloadTable:
            tableView.reloadData()
        case .initialDataFetched:
            hideActivityIndicatorView()
        case .updateListStatus(isEmpty: let result):
            switch result {
            case true:
                emptyTableLabel.isHidden = false
            case false:
                emptyTableLabel.isHidden = true
            }
        }
    }
}

// MARK: -  UITableViewDataSource

extension ShopingListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: -  UITableViewDelegate

extension ShopingListVC: UITableViewDelegate {
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

        let sectionType = ShopingListType.allCases[indexPath.section]
        let model: ShopingListModel
        switch sectionType {
        case .unchecked:
            model = viewModel.uncheckedList[indexPath.row]
            cell.configure(with: model, type: .unchecked)

        case .checked:
            model = viewModel.checkedList[indexPath.row]
            cell.configure(with: model, type: .checked)
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

// MARK: - NavigationItems & Navigation

extension ShopingListVC {
    func setupNavigationBarButtons() {
        navigationItem.setLeftBarButton(trashNavItem, animated: true)
        navigationItem.setRightBarButton(addNavItem, animated: true)
        trashNavItem.tintColor = .red
    }

    @objc func trashItemButtonTapped(_ sender: UIBarButtonItem) {
        let title = "Remove ingredients"
        let message = "Do you want to remove all ingredients from shoping list?"

        guard let coordinator = coordinator else { return }

        DispatchQueue.main.async { [weak self] in
            coordinator.presentAlert(.clearList, title: title, message: message, confirmAction: {
                self?.viewModel.clearShopingList()
                coordinator.dismissAlert()
            }) {
                coordinator.dismissAlert()
            }
        }
    }

    @objc func addItemButtonTapped(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateTo(.addItemSheet)
        }
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension ShopingListVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
