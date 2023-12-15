//
//  AddRecipeVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Combine
import Foundation
import UIKit

class AddRecipeViewModel {
    var titleText = CurrentValueSubject<String, Never>("")
    
    var difficultyRowArray: [String] = ["Easy", "Medium", "Hard"]
    
    lazy var servingRowArray: [Int] = {
        var array: [Int] = []
        for i in 1...36 {
            array.append(i)
        }
        return array
    }()
    
    lazy var timeHoursArray: [Int] = {
        var array: [Int] = []
        for i in 0...48 {
            array.append(i)
        }
        return array
    }()
    
    lazy var timeMinutesArray: [Int] = {
        var array: [Int] = []
        for i in 0...59 {
            array.append(i)
        }
        return array
    }()
    
    lazy var spicyRowArray: [String] = ["Mild", "Medium", "Hot", "Very hot"]
    
    lazy var categoryRowArray: [String] = ["Breakfast", "Lunch", "Dinner", "Desserts", "Snacks", "Beverages", "Appetizers", "Side Dishes", "Vegan", "Vegetarian"]
    
    init() {}
    
    deinit {
        print("viewmodel out")
    }
    
    func saveRecipe() {
        // Logika zapisu przepisu
    }
}
