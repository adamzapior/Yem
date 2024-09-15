//
//  RecipeSpicyModel.swift
//  Yem
//
//  Created by Adam Zapiór on 15/09/2024.
//

import Foundation

struct RecipeSpicyModel: Equatable {
    let value: String
    var displayName: String { value }

    static let mild = RecipeSpicyModel(value: "Mild")
    static let medium = RecipeSpicyModel(value: "Medium")
    static let hot = RecipeSpicyModel(value: "Hot")
    static let veryHot = RecipeSpicyModel(value: "Very hot")

    static let allCases: [RecipeSpicyModel] = [.mild, .medium, .hot, .veryHot]
}
