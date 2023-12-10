//
//  AddRecipeVM.swift
//  Yem
//
//  Created by Adam Zapiór on 09/12/2023.
//

import Foundation
import UIKit
import Combine

class AddRecipeViewModel {
    
    var titleText = CurrentValueSubject<String, Never>("")
    

    init() {
        
    }
    
    deinit {
        print("viewmodel out")
    }
    
    
    func saveRecipe() {
        // Logika zapisu przepisu
    }
   
    
}
