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

    var uncheckedList: [IngredientModel] = []
    var checkedList: [IngredientModel] = []

    private var cancellables: Set<AnyCancellable> = []

    init(repository: DataRepository) {
        self.repository = repository
    }

    func loadIngredients() async {
        let result = await repository.fetchShopingList()
        switch result {
        case .success(let result):

            let uncheckedIngredients = result.filter { !($0.isChecked ?? false) }
            let checkedIngredients = result.filter { $0.isChecked ?? false }

            uncheckedList = uncheckedIngredients
            checkedList = checkedIngredients

            reloadTable()

            print("DEBUG: loadIngredients() loaded")
        case .failure(let error):
            print("DEBUG: Error loading recipes: \(error)")
        }
    }

    func updateIngredientCheckStatus(ingredient: inout IngredientModel) {
        if let index = uncheckedList.firstIndex(where: { $0.id == ingredient.id }) {
            uncheckedList.remove(at: index)
            ingredient.isChecked = true
            checkedList.append(ingredient)
        } else if let index = checkedList.firstIndex(where: { $0.id == ingredient.id }) {
            checkedList.remove(at: index)
            ingredient.isChecked = false
            uncheckedList.append(ingredient)
        }

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
