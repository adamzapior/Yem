//
//  AddRecipeVC.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import UIKit

class AddRecipeVC: UIViewController, AddRecipeViewProtocol {
    
    var presenter: AddRecipePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .cyan
    }


}
