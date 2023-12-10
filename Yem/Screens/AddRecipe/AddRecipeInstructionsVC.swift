//
//  AddRecipeInstructionsVC.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import Foundation
import UIKit

class AddRecipeInstructionsVC: UIViewController {
    
    let vm: AddRecipeViewModel
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let pageStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 4
        return sv
    }()
    
    let pageCount = 3
    var pageViews = [UIView]()
    
    init(viewModel: AddRecipeViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        setupNavigationBarButtons()

    }
}

// MARK: - Navigation

extension AddRecipeInstructionsVC {
    func setupNavigationBarButtons() {
        let nextButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = nextButtonItem
        navigationItem.rightBarButtonItem?.tintColor = .ui.theme
        
    }
    
    @objc func saveButtonTapped(_ sender: UIBarButtonItem) {
        backToRecipesListScreen(from: self)
    }
    
    func backToRecipesListScreen(from view: UIViewController) {
        view.navigationController?.popToRootViewController(animated: true)
    }
    
}
