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
    let vm = AddRecipeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
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
    var selectedRow = 0
    
    let addPhotoView = AddPhotoView()
   
    var nameTextfield: TextfieldWithIconCell!
    var difficultyCell: PickerButtonWithIconCell!
    var servingCell: PickerButtonWithIconCell!
    var prepTimeCell: PickerButtonWithIconCell!
    var spicyCell: PickerButtonWithIconCell!
    var categoryCell: PickerButtonWithIconCell!
    
    let difficultyPickerView = UIPickerView()
    let servingsPickerView = UIPickerView()
    let prepTimePickerView = UIPickerView()
    let spicyPickerView = UIPickerView()
    let categoryPickerView = UIPickerView()
    
    let recipeDataStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Recipe info"
        
        setupNavigationBarButtons()
        
        setupScrollView()
        setupContentView()
        
        setupPageStackView()
    
        setupAddPhotoView()
        
        setupNameTextfield()
        setupDifficultyCell()
        setupServingCell()
        setupPrepTimeCell()
        setupSpicyCell()
        setupCategoryCell()
        
        configureRecipeDataStackView()
    }
    
    deinit {
        print("Add recipeVC deinit")
    }
    
    // MARK: Setup UI
    
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
    
    // Page stack
    
    private func setupPageStackView() {
        for _ in 0 ..< pageCount {
            let divider = UIView.createDivider(color: .gray)
            pageStackView.addArrangedSubview(divider)
            pageViews.append(divider) // Dodaj divider do tablicy
//            divider.widthAnchor.constraint(equalTo: pageStackView.widthAnchor, multiplier: 1/CGFloat(pageCount)).isActive = true
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
    
    private func setupNameTextfield() {
        nameTextfield = TextfieldWithIconCell(iconImage: "info", placeholderText: "Enter your recipe name")
        nameTextfield.delegate = self
    }

    private func setupDifficultyCell() {
        difficultyCell = PickerButtonWithIconCell(iconImage: "puzzlepiece.extension", textOnButton: "Select difficulty")
        difficultyCell.tag = 1
        difficultyCell.delegate = self
        
        difficultyPickerView.tag = 1
        difficultyPickerView.delegate = self
        difficultyPickerView.dataSource = self
    }
    
    private func setupServingCell() {
        servingCell = PickerButtonWithIconCell(iconImage: "person", textOnButton: "Select servings count")
        servingCell.tag = 2
        servingCell.delegate = self
        
        servingsPickerView.tag = 2
        servingsPickerView.delegate = self
        servingsPickerView.dataSource = self
    }
    
    private func setupPrepTimeCell() {
        prepTimeCell = PickerButtonWithIconCell(iconImage: "timer", textOnButton: "Select prep time")
        prepTimeCell.tag = 3
        prepTimeCell.delegate = self
        
        prepTimePickerView.tag = 3
        prepTimePickerView.delegate = self
        prepTimePickerView.dataSource = self
    }
    
    private func setupSpicyCell() {
        spicyCell = PickerButtonWithIconCell(iconImage: "leaf", textOnButton: "Select spicy")
        spicyCell.tag = 4
        spicyCell.delegate = self
        
        spicyPickerView.tag = 4
        spicyPickerView.delegate = self
        spicyPickerView.dataSource = self
    }

    private func setupCategoryCell() {
        categoryCell = PickerButtonWithIconCell(iconImage: "plus", textOnButton: "Select category")
        categoryCell.tag = 5
        categoryCell.delegate = self
        
        categoryPickerView.tag = 5
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
    }
    
    // Difficulty Picker
    
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
  
    func popUpPicker(for pickerView: UIPickerView, title: String) {
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

    // UIPickerViewDataSource and UIPickerViewDelegate methods...
}

extension AddRecipeVC: TextfieldWithIconCellDelegate {
    func textFieldDidEndEditing(_ cell: TextfieldWithIconCell, didUpdateText text: String) {
        //
        
    }
}

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
            label.text = vm.difficultyRowArray[row]
        case 2:
            label.text = vm.servingRowArray[row].description
        case 3:
            label.text = vm.timeHoursArray[row].description
        case 4:
            label.text = vm.spicyRowArray[row]
        case 5:
            label.text = vm.categoryRowArray[row]
        default:
            label.text = ""
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1: // For difficulty
            let selectedDifficulty = vm.difficultyRowArray[row]
            difficultyCell.textOnButton.text = selectedDifficulty
            difficultyCell.textOnButton.textColor = .ui.primaryText
        case 2:
            let selectedServing = vm.servingRowArray[row].description
            servingCell.textOnButton.text = "\(selectedServing) (serving)"
            servingCell.textOnButton.textColor = .ui.primaryText
        case 3:
            let selectedDifficulty = vm.timeHoursArray[row].description
            prepTimeCell.textOnButton.text = selectedDifficulty
            prepTimeCell.textOnButton.textColor = .ui.primaryText
        case 4:
            let selectedDifficulty = vm.spicyRowArray[row]
            spicyCell.textOnButton.text = selectedDifficulty
            spicyCell.textOnButton.textColor = .ui.primaryText
        case 5:
            let selectedDifficulty = vm.categoryRowArray[row]
            categoryCell.textOnButton.text = selectedDifficulty
            categoryCell.textOnButton.textColor = .ui.primaryText
        default:
            break
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return vm.difficultyRowArray.count
        case 2:
            return vm.servingRowArray.count
        case 3:
            return vm.timeHoursArray.count
        case 4:
            return vm.spicyRowArray.count
        case 5:
            return vm.categoryRowArray.count
        default:
            break
        }
        return pickerView.numberOfComponents
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
}

extension AddRecipeVC {
    func setupNavigationBarButtons() {
        let nextButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem = nextButtonItem
        navigationItem.rightBarButtonItem?.tintColor = .ui.theme
    }

    @objc func saveTapped(_ sender: UIBarButtonItem) {
//        backToRecipesListScreen(from: self)
        pushToNextScreen(from: self, toView: AddRecipeIngredientsVC(viewModel: vm))
    }
    
    func backToRecipesListScreen(from view: UIViewController) {
        view.navigationController?.popToRootViewController(animated: true)
    }
    
    func pushToNextScreen(from view: UIViewController, toView: UIViewController) {
//        toView.hidesBottomBarWhenPushed = true
        view.navigationController?.pushViewController(toView, animated: true)
    }
}
