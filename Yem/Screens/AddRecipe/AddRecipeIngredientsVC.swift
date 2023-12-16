//
//  AddRecipe2VC.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import UIKit

class AddRecipeIngredientsVC: UIViewController {
    
    // MARK: - ViewModel
    let viewModel: AddRecipeViewModel
    
    // MARK: - View properties
    let pageStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 4
        return sv
    }()
    
    let pageCount = 3
    var pageViews = [UIView]()
    
    private let tableView = UITableView()
    private let tableViewFooter = IngredientsTableFooterView()
    private let tableViewHeader = IngredientsTableHeaderView()
    
    // MARK: - Lifecycle
    
    init(viewModel: AddRecipeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        title = "Ingredients"
        
        setupNavigationBarButtons()
        
        setupTableView()
        setupTableViewHeader()
        setupTableViewFooter()

    }
    
    // MARK: - Setup UI
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(IngredientsCell.self, forCellReuseIdentifier: IngredientsCell.id)
        
        tableView.backgroundColor = UIColor.ui.background
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableViewFooter() {
        tableView.addSubview(tableViewFooter)
        tableView.tableFooterView = tableViewFooter
        tableViewFooter.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
        tableViewFooter.backgroundColor = UIColor.ui.background
    }

    private func setupTableViewHeader() {
        tableView.addSubview(tableViewHeader)
        tableView.tableHeaderView = tableViewHeader
        tableViewHeader.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 36)
        tableViewHeader.backgroundColor = UIColor.ui.background
        
    }
}

// MARK: -  TableView delegate & data source

extension AddRecipeIngredientsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.ingredientsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IngredientsCell.id, for: indexPath) as? IngredientsCell else {
            fatalError("IngredientsCell error")
        }
        cell.configure(with: viewModel.ingredientsList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


// MARK: - Navigation

extension AddRecipeIngredientsVC {
    func setupNavigationBarButtons() {
        let nextButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonTapped))
        navigationItem.rightBarButtonItem = nextButtonItem
        navigationItem.rightBarButtonItem?.tintColor = .ui.theme
        
    }
    
    @objc func nextButtonTapped(_ sender: UIBarButtonItem) {
        pushToNextScreen(from: self, toView: AddRecipeInstructionsVC(viewModel: viewModel))
    }
    
    func pushToNextScreen(from view: UIViewController, toView: UIViewController) {
        view.navigationController?.pushViewController(toView, animated: true)
    }
    
}
