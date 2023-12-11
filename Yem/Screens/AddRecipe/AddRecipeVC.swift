//
//  AddRecipeVC.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import Combine
import SnapKit
import UIKit

class AddRecipeVC: UIViewController, TextfieldWithIconCellDelegate {
    func textFieldDidEndEditing(_ cell: TextfieldWithIconCell, didUpdateText text: String) {
        //
    }
    
    
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
    
    
    
    
    let addPhotoView = AddPhotoView()
    
    let titleForTitleTextField = ReusableTextLabel(fontStyle: .footnote, fontWeight: .regular, textColor: .orange)
    var titleTextFieldView: TitleTextFieldView!
    
    let titleForDifficultyPicker = ReusableTextLabel(fontStyle: .footnote, fontWeight: .regular, textColor: .orange)
    let difficultyViewButton = UIButton()
    let difficultyTitleLabel = UILabel()
    let difficultyPickerView = UIPickerView()
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2
    var selectedRow = 0
    
    var backGroundColours: KeyValuePairs = [
        "WHITE": UIColor.white,
        "GRAY": UIColor.lightGray,
        "BLUE": UIColor.blue,
        "YELLOW": UIColor.yellow,
        "RED": UIColor.red,
        "GREEN": UIColor.green
    ]
    
    /// Servings
    let titleForServingsPicker = ReusableTextLabel(fontStyle: .footnote, fontWeight: .regular, textColor: .orange)
    let servingsViewButton = UIButton()
    let servingsLabel = UILabel()
    let servingsPickerView = UIPickerView()
    
    /// PrepTime
    let titleForPrepTimePicker = ReusableTextLabel(fontStyle: .footnote, fontWeight: .regular, textColor: .orange)
    let prepTimeViewButton = UIButton()
    let prepTimeLabel = UILabel()
    let prepTimePickerView = UIPickerView()
    
    let recipeDataStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()
    
    var nameTextfield: TextfieldWithIconCell!
    var difficultyCell: PickerButtonWithIconCell!
    var servingCell: PickerButtonWithIconCell!
    var prepTimeCell: PickerButtonWithIconCell!
    var spicyCell: PickerButtonWithIconCell!
    var categoryCell: PickerButtonWithIconCell!
    
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

//        
//        setupTitleForServingsPicker()
//        setupServingPickerViewButton()
//        
//        setupTitleForPrepTimePicker()
//        setupPrepTimePickerViewButton()

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
        for _ in 0..<pageCount {
            let divider = UIView.createDivider(color: .gray)
            pageStackView.addArrangedSubview(divider)
            pageViews.append(divider) // Dodaj divider do tablicy
//            divider.widthAnchor.constraint(equalTo: pageStackView.widthAnchor, multiplier: 1/CGFloat(pageCount)).isActive = true
        }
        
        pageViews[0].backgroundColor = .ui.theme
        
        contentView.addSubview(pageStackView)
        pageStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
    }
    
    // Add photo UI
    
    private func setupAddPhotoView() {
        contentView.addSubview(addPhotoView)
    
        addPhotoView.snp.makeConstraints { make in
            make.top.equalTo(pageStackView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(150)
        }
    }
    
    private func setupNameTextfield() {
        nameTextfield = TextfieldWithIconCell(iconImage: "pencil", placeholderText: "Enter your recipe name")
        nameTextfield.delegate = self
        contentView.addSubview(nameTextfield)
        
        nameTextfield.snp.makeConstraints { make in
            make.top.equalTo(addPhotoView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.greaterThanOrEqualTo(50)
        }
    }

    
    // Difficulty Picker
    
    private func configureRecipeDataStackView() {
        contentView.addSubview(recipeDataStack)
        recipeDataStack.addArrangedSubview(difficultyCell)
        recipeDataStack.addArrangedSubview(servingCell)
        recipeDataStack.addArrangedSubview(prepTimeCell)
        recipeDataStack.addArrangedSubview(spicyCell)
        recipeDataStack.addArrangedSubview(categoryCell)

        
        recipeDataStack.snp.makeConstraints { make in
            make.top.equalTo(nameTextfield.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(18)
        }
    }
    
    private func setupDifficultyCell() {
        difficultyCell = PickerButtonWithIconCell(iconImage: "puzzlepiece.extension", textOnButton: "Select difficulty")
        difficultyCell.tag = 1
        difficultyCell.delegate = self
//        contentView.addSubview(difficultyCell)
//        
//        difficultyCell.snp.makeConstraints { make in
//            make.top.equalTo(titleTextFieldView.snp.bottom).offset(12)
//            make.leading.trailing.equalToSuperview().inset(18)
//            make.height.greaterThanOrEqualTo(50)
//        }
    }
    
    private func setupServingCell() {
        servingCell = PickerButtonWithIconCell(iconImage: "person", textOnButton: "Select servings count")
        servingCell.tag = 2
        servingCell.delegate = self
//        contentView.addSubview(servingCell)
//        
//        servingCell.snp.makeConstraints { make in
//            make.top.equalTo(difficultyCell.snp.bottom).offset(12)
//            make.leading.trailing.equalToSuperview().inset(18)
//            make.height.greaterThanOrEqualTo(50)
//        }
    }
    
    private func setupPrepTimeCell() {
        prepTimeCell = PickerButtonWithIconCell(iconImage: "timer", textOnButton: "Select prep time")
        prepTimeCell.tag = 3
        prepTimeCell.delegate = self
        contentView.addSubview(prepTimeCell)
        
//        prepTimeCell.snp.makeConstraints { make in
//            make.top.equalTo(servingCell.snp.bottom).offset(12)
//            make.leading.trailing.equalToSuperview().inset(18)
//            make.height.greaterThanOrEqualTo(50)
//        }
    }
    
    private func setupSpicyCell() {
        spicyCell = PickerButtonWithIconCell(iconImage: "leaf", textOnButton: "Select spicy")
        spicyCell.tag = 4
        spicyCell.delegate = self
//        contentView.addSubview(spicyCell)
//        
//        spicyCell.snp.makeConstraints { make in
//            make.top.equalTo(prepTimeCell.snp.bottom).offset(12)
//            make.leading.trailing.equalToSuperview().inset(18)
//            make.height.greaterThanOrEqualTo(50)
//        }
    }

//    
//    // Servings Picker with title
//    
//    private func setupTitleForServingsPicker() {
//        contentView.addSubview(titleForServingsPicker)
//        titleForServingsPicker.text = "SERVINGS*"
//        
//        titleForServingsPicker.snp.makeConstraints { make in
//            make.top.equalTo(difficultyViewButton.snp.bottom).offset(12)
//            make.leading.trailing.equalToSuperview().inset(24)
//        }
//    }
//    
//    private func setupServingPickerViewButton() {
//        contentView.addSubview(servingsViewButton)
//        
//        contentView.addSubview(servingsLabel)
//        servingsLabel.text = "Select servings count"
//        servingsLabel.textColor = .ui.secondaryText
//        servingsLabel.snp.makeConstraints { make in
//            make.leading.equalTo(servingsViewButton.snp.leading).offset(12) // Adjust the offset as needed
//            make.centerY.equalTo(servingsViewButton.snp.centerY)
//        }
//        
//        // Configure the button
//        servingsViewButton.backgroundColor = .ui.primaryContainer
//        servingsViewButton.layer.cornerRadius = 20
//        servingsViewButton.addTarget(self, action: #selector(popUpPicker(_:)), for: .touchUpInside)
//
//        // Set constraints for pickerViewButton
//        servingsViewButton.snp.makeConstraints { make in
//            make.top.equalTo(titleForServingsPicker.snp.bottom).offset(4)
//            make.leading.trailing.equalToSuperview().inset(12)
//            make.height.greaterThanOrEqualTo(50)
//        }
//    }
//    
//    // Prep Time with title
//    
//    private func setupTitleForPrepTimePicker() {
//        contentView.addSubview(titleForPrepTimePicker)
//        titleForPrepTimePicker.text = "PREP TIME*"
//        
//        titleForPrepTimePicker.snp.makeConstraints { make in
//            make.top.equalTo(servingsViewButton.snp.bottom).offset(12)
//            make.leading.trailing.equalToSuperview().inset(24)
//        }
//    }
//    
//    private func setupPrepTimePickerViewButton() {
//        contentView.addSubview(prepTimeViewButton)
//        
//        contentView.addSubview(prepTimeLabel)
//        prepTimeLabel.text = "Select prep time"
//        prepTimeLabel.textColor = .ui.secondaryText
//        prepTimeLabel.snp.makeConstraints { make in
//            make.leading.equalTo(prepTimeViewButton.snp.leading).offset(12) 
//            make.centerY.equalTo(prepTimeViewButton.snp.centerY)
//        }
//        
//        // Configure the button
//        prepTimeViewButton.backgroundColor = .ui.primaryContainer
//        prepTimeViewButton.layer.cornerRadius = 20
//        prepTimeViewButton.addTarget(self, action: #selector(popUpPicker(_:)), for: .touchUpInside)
//
//        // Set constraints for pickerViewButton
//        prepTimeViewButton.snp.makeConstraints { make in
//            make.top.equalTo(titleForPrepTimePicker.snp.bottom).offset(4)
//            make.leading.trailing.equalToSuperview().inset(12)
//            make.height.greaterThanOrEqualTo(50)
//        }
//    }
    
    private func setupCategoryCell() {
        categoryCell = PickerButtonWithIconCell(iconImage: "plus", textOnButton: "Select category")
        categoryCell.delegate = self
//        contentView.addSubview(categoryCell)
//        
//        categoryCell.snp.makeConstraints { make in
//            make.top.equalTo(spicyCell.snp.bottom).offset(4)
//            make.leading.trailing.equalToSuperview().inset(18)
//            make.height.greaterThanOrEqualTo(50)
//        }
    }


    /// https://www.youtube.com/watch?v=9Fy0Gc1l3VE
    @objc func popUpPicker(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: view.frame.width - 20, height: 250)

        difficultyPickerView.dataSource = self
        difficultyPickerView.delegate = self
        difficultyPickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        vc.view.addSubview(difficultyPickerView)
        difficultyPickerView.frame = CGRect(x: 0, y: 0, width: vc.preferredContentSize.width, height: 250)

        let alert = UIAlertController(title: "Select Background Colour", message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = difficultyViewButton
        alert.popoverPresentationController?.sourceRect = difficultyViewButton.bounds
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: { _ in
            self.selectedRow = self.difficultyPickerView.selectedRow(inComponent: 0)
            let selected = Array(self.backGroundColours)[self.selectedRow]
            self.difficultyTitleLabel.text = selected.value.description
            self.difficultyTitleLabel.textColor = .ui.primaryText

//            self.pickerViewButton.setTitle(selected.key, for: .normal)
        }))

        present(alert, animated: true, completion: nil)
    }

    // UIPickerViewDataSource and UIPickerViewDelegate methods...
}

extension AddRecipeVC: PickerButtonWithIconCellDelegate {
    func pickerButtonWithIconCellDidTapButton(_ cell: PickerButtonWithIconCell) {
        print("my new button tapped")
        categoryCell.textOnButton.text = "yyy"
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


extension AddRecipeVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = Array(backGroundColours)[row].key
        label.sizeToFit()
        return label
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return backGroundColours.count
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
}
