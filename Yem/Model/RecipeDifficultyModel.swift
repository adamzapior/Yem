//
//  RecipeDifficultyModel.swift
//  Yem
//
//  Created by Adam Zapiór on 15/09/2024.
//

import Foundation

struct RecipeDifficultyModel {
    let value: String
    var displayName: String { value }

    static let easy = RecipeDifficultyModel(value: "Easy")
    static let medium = RecipeDifficultyModel(value: "Medium")
    static let hard = RecipeDifficultyModel(value: "Hard")

    static let allCases: [RecipeDifficultyModel] = [.easy, .medium, .hard]
}
