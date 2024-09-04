//
//  ShopingListVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import Foundation
import LifetimeTracker

extension ShopingListVM {
    enum Input {
        case viewDidLoad
    }

    enum Output {
        case reloadTable
        case initialDataFetched
        case updateListStatus(isEmpty: Bool)
    }
}

final class ShopingListVM {
    private let repository: DataRepositoryProtocol

    var uncheckedList: [ShopingListModel] = []
    var checkedList: [ShopingListModel] = []

    let inputEvent = PassthroughSubject<Input, Never>()
    private var inputPublisher: AnyPublisher<Input, Never> {
        inputEvent.eraseToAnyPublisher()
    }

    private let outputEvent = PassthroughSubject<Output, Never>()
    var outputPublisher: AnyPublisher<Output, Never> {
        outputEvent.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: Lifecycle

    init(repository: DataRepositoryProtocol) {
        self.repository = repository

        repository.shopingListPublisher
            .sink(receiveValue: { [unowned self] _ in
                Task {
                    self.reloadShopingList()
                }
            })
            .store(in: &cancellables)

        observeInput()

#if DEBUG
        trackLifetime()
#endif
    }

    // MARK: - Public methods

    func loadShopingList() {
        Task {
            uncheckedList = repository.fetchShopingList(isChecked: false).successOrEmpty()
            checkedList = repository.fetchShopingList(isChecked: true).successOrEmpty()

            outputEvent.send(.initialDataFetched)
            checkIfShoppingListIsEmpty()
            outputEvent.send(.reloadTable)
        }
    }

    func updateIngredientCheckStatus(ingredient: inout ShopingListModel) {
        if let index = uncheckedList.firstIndex(where: { $0.id == ingredient.id }) {
            uncheckedList.remove(at: index)
            ingredient.isChecked = true
            checkedList.append(ingredient)
        } else if let index = checkedList.firstIndex(where: { $0.id == ingredient.id }) {
            checkedList.remove(at: index)
            ingredient.isChecked = false
            uncheckedList.append(ingredient)
        }

        repository.updateShopingList(shopingList: ingredient)
        outputEvent.send(.reloadTable)
    }

    func clearShopingList() {
        repository.clearShopingList()
    }

    // MARK: - Private methods

    private func reloadShopingList() {
        Task {
            uncheckedList = repository.fetchShopingList(isChecked: false).successOrEmpty()
            checkedList = repository.fetchShopingList(isChecked: true).successOrEmpty()

            checkIfShoppingListIsEmpty()
            outputEvent.send(.reloadTable)
        }
    }

    private func checkIfShoppingListIsEmpty() {
        let isEmpty = uncheckedList.isEmpty && checkedList.isEmpty

        switch isEmpty {
        case true:
            outputEvent.send(.updateListStatus(isEmpty: true))
        case false:
            outputEvent.send(.updateListStatus(isEmpty: false))
        }
    }
}

// MARK: - Observed Input & Handling

extension ShopingListVM {
    private func observeInput() {
        inputPublisher
            .sink { [unowned self] event in
                switch event {
                case .viewDidLoad:
                    self.handleViewDidLoad()
                }
            }
            .store(in: &cancellables)
    }

    private func handleViewDidLoad() {
        loadShopingList()
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension ShopingListVM: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif

// MARK: - Result extension

extension Result where Success == [ShopingListModel], Failure == Error {
    func successOrEmpty() -> [ShopingListModel] {
        switch self {
        case .success(let result):
            return result
        case .failure(let error):
            print("DEBUG: Error loading recipes: \(error)")
            return []
        }
    }
}
