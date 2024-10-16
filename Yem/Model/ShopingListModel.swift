//
//  ShopingListModel.swift
//  Yem
//
//  Created by Adam Zapiór on 17/03/2024.
//

import Foundation

struct ShopingListModel: Equatable {
    var id: UUID
    var isChecked: Bool
    var name: String
    var value: String
    var valueType: String
}

enum ShopingListType: Int, CaseIterable {
    case unchecked
    case checked
}
