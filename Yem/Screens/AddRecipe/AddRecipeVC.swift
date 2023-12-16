//
//  AddRecipeVC.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import Combine
import SnapKit
import UIKit

class AddRecipeVC: UIViewController {
    // MARK: - ViewModel
    
    let viewModel = AddRecipeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - View properties
    
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
    
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2
    
    let addPhotoView = AddPhotoView()
   
    var nameTextfield = TextfieldWithIconCell(iconImage: "info.square", placeholderText: "Enter your recipe name")
    var difficultyCell = PickerButtonWithIconCell(iconImage: "puzzlepiece.extension", textOnButton: "Select difficulty")
    var servingCell = PickerButtonWithIconCell(iconImage: "person", textOnButton: "Select servings count")
    var prepTimeCell = PickerButtonWithIconCell(iconImage: "timer", textOnButton: "Select prep time")
    var spicyCell = PickerButtonWithIconCell(iconImage: "leaf", textOnButton: "Select spicy")
    var categoryCell = PickerButtonWithIconCell(iconImage: "book.pages", textOnButton: "Select category")
    
    lazy var difficultyPickerView = UIPickerView()
    lazy var servingsPickerView = UIPickerView()
    lazy var prepTimePickerView = UIPickerView()
    lazy var spicyPickerView = UIPickerView()
    lazy var categoryPickerView = UIPickerView()
    
    let recipeDataStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Recipe info"
        
        setupNavigationBarButtons()
        
        setupScrollView()
        setupContentView()
        
        setupPageStackView()
    
        setupAddPhotoView()
        configureRecipeDataStackView()
        setupDelegateOfViewItems()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        print("Add recipeVC deinit")
    }
    
    // MARK: - UI Setup

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
    
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupContentView() {
        scrollView.addSubview(contentView)
    
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
    
        let hConstant = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        hConstant.isActive = true
        hConstant.priority = UILayoutPriority(50) /// always less priority than ScrollView
    }
        
    private func setupPageStackView() {
        for _ in 0 ..< pageCount {
            let divider = UIView.createDivider(color: .gray)
            pageStackView.addArrangedSubview(divider)
            pageViews.append(divider)
        }
        
        pageViews[0].backgroundColor = .ui.theme
        
        contentView.addSubview(pageStackView)
        pageStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(12)
        }
    }
    
    // Add photo UI
    
    private func setupAddPhotoView() {
        contentView.addSubview(addPhotoView)
    
        addPhotoView.snp.makeConstraints { make in
            make.top.equalTo(pageStackView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(200)
        }
    }
    
    private func configureRecipeDataStackView() {
        contentView.addSubview(recipeDataStack)
        recipeDataStack.addArrangedSubview(nameTextfield)
        recipeDataStack.addArrangedSubview(difficultyCell)
        recipeDataStack.addArrangedSubview(servingCell)
        recipeDataStack.addArrangedSubview(prepTimeCell)
        recipeDataStack.addArrangedSubview(spicyCell)
        recipeDataStack.addArrangedSubview(categoryCell)

        recipeDataStack.snp.makeConstraints { make in
            make.top.equalTo(addPhotoView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
        }
    }

//    /// https://www.youtube.com/watch?v=9Fy0Gc1l3VE
    
    // MARK: - methods

    func popUpPicker(for pickerView: UIPickerView, title: String) {
        view.endEditing(true)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.tag = pickerView.tag // Ensure the picker view has the correct tag

        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: view.frame.width - 20, height: 180)
        pickerView.frame = CGRect(x: 0, y: 0, width: vc.preferredContentSize.width, height: 180)
        vc.view.addSubview(pickerView)

        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.setValue(vc, forKey: "contentViewController")

        let selectAction = UIAlertAction(title: "Select", style: .default, handler: { _ in
            // Handle selection here if needed
        })

        selectAction.setValue(UIColor.orange, forKey: "titleTextColor")

        alert.addAction(selectAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Tags & DataSource

extension AddRecipeVC {
    private func setupDelegateOfViewItems() {
        setupNameTextfield()
        setupDifficultyCell()
        setupServingCell()
        setupPrepTimeCell()
        setupSpicyCell()
        setupCategoryCell()
    }
    
    private func setupNameTextfield() {
        nameTextfield.delegate = self
    }

    private func setupDifficultyCell() {
        difficultyCell.tag = 1
        difficultyCell.delegate = self
        
        difficultyPickerView.tag = 1
        difficultyPickerView.delegate = self
        difficultyPickerView.dataSource = self
    }
    
    private func setupServingCell() {
        servingCell.tag = 2
        servingCell.delegate = self
        
        servingsPickerView.tag = 2
        servingsPickerView.delegate = self
        servingsPickerView.dataSource = self
    }
    
    private func setupPrepTimeCell() {
        prepTimeCell.tag = 3
        prepTimeCell.delegate = self
        
        prepTimePickerView.tag = 3
        prepTimePickerView.delegate = self
        prepTimePickerView.dataSource = self
    }
    
    private func setupSpicyCell() {
        spicyCell.tag = 4
        spicyCell.delegate = self
        
        spicyPickerView.tag = 4
        spicyPickerView.delegate = self
        spicyPickerView.dataSource = self
    }

    private func setupCategoryCell() {
        categoryCell.tag = 5
        categoryCell.delegate = self
        
        categoryPickerView.tag = 5
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
    }
}

// MARK: - Textfield delegate/dataSource

extension AddRecipeVC: TextfieldWithIconCellDelegate {
    func textFieldDidEndEditing(_ cell: TextfieldWithIconCell, didUpdateText text: String) {
        if let text = cell.textField.text {
            viewModel.recipeTitle = text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Ukrywa klawiaturę
        return true
    }
}

// MARK: - Button delegate/dataSource

extension AddRecipeVC: PickerButtonWithIconCellDelegate {
    func pickerButtonWithIconCellDidTapButton(_ cell: PickerButtonWithIconCell) {
        switch cell.tag {
        case 1:
            popUpPicker(for: difficultyPickerView, title: "Select difficulty of recipe")
        case 2:
            popUpPicker(for: servingsPickerView, title: "Select servings count")
        case 3:
            popUpPicker(for: prepTimePickerView, title: "Select time perp")
        case 4:
            popUpPicker(for: spicyPickerView, title: "Select spicy")
        case 5:
            popUpPicker(for: categoryPickerView, title: "Select category")
        default:
            break
        }
    }
}

// MARK: - PickerView delegate/dataSource

extension AddRecipeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let reuseLabel = view as? UILabel {
            label = reuseLabel
        } else {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
            label.textAlignment = .center // Dostosuj wyrównanie tekstu
        }
        switch pickerView.tag {
        case 1:
            label.text = viewModel.difficultyRowArray[row]
        case 2:
            label.text = viewModel.servingRowArray[row].description
        case 3:
            switch component {
            case 0:
                label.text = "\(viewModel.timeHoursArray[row].description) h"
            case 1:
                label.text = "\(viewModel.timeMinutesArray[row].description) min"
            default:
                break
            }
        case 4:
            label.text = viewModel.spicyRowArray[row]
        case 5:
            label.text = viewModel.categoryRowArray[row]
        default:
            label.text = ""
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1: // For difficulty
            let selectedDifficulty = viewModel.difficultyRowArray[row]
            difficultyCell.textOnButton.text = selectedDifficulty
            difficultyCell.textOnButton.textColor = .ui.primaryText
            viewModel.difficulty = selectedDifficulty
        case 2:
            let selectedServing = viewModel.servingRowArray[row]
            servingCell.textOnButton.text = "\(selectedServing.description) (serving)"
            servingCell.textOnButton.textColor = .ui.primaryText
            viewModel.serving = selectedServing
        case 3:
            if component == 0 {
                let selectedHours = viewModel.timeHoursArray[row].description
                viewModel.prepTimeHours = selectedHours
            } else {
                let selectedMinutes = viewModel.timeMinutesArray[row].description
                viewModel.prepTimeMinutes = selectedMinutes
            }
            
            var hours: String = ""
            var minutes: String = ""
            
            /// hours for '2 - 48'
            if viewModel.prepTimeHours != "0" &&
                viewModel.prepTimeHours != "1" &&
                viewModel.prepTimeHours != "" {
                hours = "\(viewModel.prepTimeHours) hours"
            }
            
            /// hours for '1'
            if viewModel.prepTimeHours == "1" {
                hours = "\(viewModel.prepTimeHours) hour"
            }
            
            /// minutes
            if viewModel.prepTimeMinutes != "0" && 
                viewModel.prepTimeMinutes != "" {
                minutes = "\(viewModel.prepTimeMinutes) min"
            }
            
            prepTimeCell.textOnButton.text = "\(hours) \(minutes)"
            prepTimeCell.textOnButton.textColor = .ui.primaryText
        case 4:
            let selectedSpicy = viewModel.spicyRowArray[row]
            spicyCell.textOnButton.text = selectedSpicy
            spicyCell.textOnButton.textColor = .ui.primaryText
            viewModel.spicy = selectedSpicy
        case 5:
            let selectedCategory = viewModel.categoryRowArray[row]
            categoryCell.textOnButton.text = selectedCategory
            categoryCell.textOnButton.textColor = .ui.primaryText
            viewModel.category = selectedCategory
        default:
            break
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return 2
        case 4:
            return 1
        case 5:
            return 1
        default:
            return 1
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return viewModel.difficultyRowArray.count
        case 2:
            return viewModel.servingRowArray.count
        case 3:
            switch component {
            case 0:
                return viewModel.timeHoursArray.count
            case 1:
                return viewModel.timeMinutesArray.count
            default:
                break
            }
            return viewModel.timeHoursArray.count
        case 4:
            return viewModel.spicyRowArray.count
        case 5:
            return viewModel.categoryRowArray.count
        default:
            break
        }
        return pickerView.numberOfComponents
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
}

// MARK: - Navigation

extension AddRecipeVC {
    func setupNavigationBarButtons() {
        let nextButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = nextButtonItem
        navigationItem.rightBarButtonItem?.tintColor = .ui.theme
    }

    @objc func saveTapped(_ sender: UIBarButtonItem) {
//        backToRecipesListScreen(from: self)
        pushToNextScreen(from: self, toView: AddRecipeIngredientsVC(viewModel: viewModel))
    }
    
    func backToRecipesListScreen(from view: UIViewController) {
        view.navigationController?.popToRootViewController(animated: true)
    }
    
    func pushToNextScreen(from view: UIViewController, toView: UIViewController) {
//        toView.hidesBottomBarWhenPushed = true
        view.navigationController?.pushViewController(toView, animated: true)
    }
}