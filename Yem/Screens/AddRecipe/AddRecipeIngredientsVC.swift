//
//  AddRecipe2VC.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import UIKit

class AddRecipeIngredientsVC: UIViewController {
    let vm: AddRecipeViewModel
    
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
    
    init(viewModel: AddRecipeViewModel) {
        self.vm = viewModel
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

//        setupScrollView()
//        setupContentView()
//        setupPageStackView()
    }
    
    // MARK: Setup UI
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.backgroundColor = UIColor.ui.background
        tableView.showsVerticalScrollIndicator = false
        
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
        
//        tableViewHeader.snp.makeConstraints { make in
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.height.greaterThanOrEqualTo(50)
//        }
    }

    private func setupTableViewHeader() {
        tableView.addSubview(tableViewHeader)
        tableView.tableHeaderView = tableViewHeader
        tableViewHeader.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 36)
        tableViewHeader.backgroundColor = UIColor.ui.background
        
    }
}

extension AddRecipeIngredientsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Row \(indexPath.row)"
        return cell
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
        pushToNextScreen(from: self, toView: AddRecipeInstructionsVC(viewModel: vm))
    }
    
    func pushToNextScreen(from view: UIViewController, toView: UIViewController) {
        view.navigationController?.pushViewController(toView, animated: true)
    }
    
}
