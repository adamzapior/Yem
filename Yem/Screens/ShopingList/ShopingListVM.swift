//
//  ShopingListVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import Foundation

protocol ShopingListVMDelegate: AnyObject {
    func reloadTable()
}

final class ShopingListVM {
    weak var delegate: ShopingListVMDelegate?
    let repository: DataRepository

    var uncheckedList: [ShopingListModel] = []
    var checkedList: [ShopingListModel] = []

    private var cancellables: Set<AnyCancellable> = []

    init(repository: DataRepository) {
        self.repository = repository

        repository.shopingListPublisher
            .sink(receiveValue: { [weak self] _ in
                Task { [weak self] in
                    self?.loadShopingList()
                }
            })
            .store(in: &cancellables)
    }

    func loadShopingList() {
        let uncheckedResult = repository.fetchShopingList(isChecked: false)
        let checkedResult = repository.fetchShopingList(isChecked: true)

        switch uncheckedResult {
        case .success(let result):
            uncheckedList = result
        case .failure(let error):
            print("DEBUG: Error loading recipes: \(error)")
        }

        switch checkedResult {
        case .success(let result):
            checkedList = result
        case .failure(let error):
            print("DEBUG: Error loading recipes: \(error)")
        }

        reloadTable()
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
        reloadTable()
    }
}

extension ShopingListVM: ShopingListVMDelegate {
    func reloadTable() {
        DispatchQueue.main.async {
            self.delegate?.reloadTable()
        }
    }
}

enum ShopingListType: Int, CaseIterable {
    case unchecked
    case checked
}
