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
    
//    let divider1 = UIView()
    let divider = UIView()
    
    /// Ingridients
    
    let titleForIngridients = ReusableTextLabel(fontStyle: .footnote, fontWeight: .regular, textColor: .orange)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Recipe info"
        
        
        setupNavigationBarButtons()
        
        setupScrollView()
        setupContentView()
        
        setupPageStackView()
    
        setupAddPhotoView()
//        setupFirstDivider()
        
        setupTitleForTitleTextField()
        setupTitleTextField()
        
        print("test")
        setupTitleForDifficultyPicker()
        setupPickerViewButton()
        
        setupTitleForServingsPicker()
        setupServingPickerViewButton()
        
        setupTitleForPrepTimePicker()
        setupPrepTimePickerViewButton()
        
        setupDivider()
        
        setupTitleForIngridients()
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
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(150)
        }
    }
//    
//    private func setupFirstDivider() {
//        contentView.addSubview(divider1)
//        
//        divider1.backgroundColor = UIColor.ui.divider
//        divider1.snp.makeConstraints { make in
//            make.top.equalTo(addPhotoView.snp.bottom).offset(24)
//            make.leading.equalToSuperview().offset(12)
//            make.trailing.equalToSuperview().offset(-12)
//            make.height.equalTo(0.5)
//        }
//    }
    
    // Title TextField with title
    
    private func setupTitleForTitleTextField() {
        contentView.addSubview(titleForTitleTextField)
        titleForTitleTextField.text = "RECIPE TITLE*"
        
        titleForTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(addPhotoView.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-12)
//            make.bottom.equalTo(titleTextFieldView.snp.top).offset(-4)
        }
    }
    
    private func setupTitleTextField() {
        titleTextFieldView = TitleTextFieldView(textFieldString: vm.titleText.value)
        
        contentView.addSubview(titleTextFieldView)
        titleTextFieldView.snp.makeConstraints { make in
            make.top.equalTo(titleForTitleTextField.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.greaterThanOrEqualTo(50)
        }
    }
    
    // Difficulty Picker with title
    
    private func setupTitleForDifficultyPicker() {
        contentView.addSubview(titleForDifficultyPicker)
        titleForDifficultyPicker.text = "DIFFICULTY*"
        
        titleForDifficultyPicker.snp.makeConstraints { make in
            make.top.equalTo(titleTextFieldView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func setupPickerViewButton() {
        contentView.addSubview(difficultyViewButton)
        contentView.addSubview(difficultyTitleLabel)
        
        // Configure the label
        difficultyTitleLabel.text = "Select Background Colour"
        difficultyTitleLabel.textColor = .ui.secondaryText

        // Configure the button
        difficultyViewButton.backgroundColor = .ui.primaryContainer
        difficultyViewButton.layer.cornerRadius = 20
        difficultyViewButton.addTarget(self, action: #selector(popUpPicker(_:)), for: .touchUpInside)
        
        difficultyTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(difficultyViewButton.snp.leading).offset(12)
            make.centerY.equalTo(difficultyViewButton.snp.centerY)
//            make.top.equalTo(titleForDifficultyPicker.snp.bottom).offset(4)
//            make.leading.equalToSuperview().offset(12) // Adjust the offset as needed
//            make.width.equalTo(screenWidth / 2 - 18)
//            make.height.greaterThanOrEqualTo(50)
        }

        // Set constraints for pickerViewButton
        difficultyViewButton.snp.makeConstraints { make in
            make.top.equalTo(titleForDifficultyPicker.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.greaterThanOrEqualTo(50)
        }
    }
    
    // Servings Picker with title
    
    private func setupTitleForServingsPicker() {
        contentView.addSubview(titleForServingsPicker)
        titleForServingsPicker.text = "SERVINGS*"
        
        titleForServingsPicker.snp.makeConstraints { make in
            make.top.equalTo(difficultyViewButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func setupServingPickerViewButton() {
        contentView.addSubview(servingsViewButton)
        
        contentView.addSubview(servingsLabel)
        servingsLabel.text = "Select servings count"
        servingsLabel.textColor = .ui.secondaryText
        servingsLabel.snp.makeConstraints { make in
            make.leading.equalTo(servingsViewButton.snp.leading).offset(12) // Adjust the offset as needed
            make.centerY.equalTo(servingsViewButton.snp.centerY)
        }
        
        // Configure the button
        servingsViewButton.backgroundColor = .ui.primaryContainer
        servingsViewButton.layer.cornerRadius = 20
        servingsViewButton.addTarget(self, action: #selector(popUpPicker(_:)), for: .touchUpInside)

        // Set constraints for pickerViewButton
        servingsViewButton.snp.makeConstraints { make in
            make.top.equalTo(titleForServingsPicker.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.greaterThanOrEqualTo(50)
        }
    }
    
    // Prep Time with title
    
    private func setupTitleForPrepTimePicker() {
        contentView.addSubview(titleForPrepTimePicker)
        titleForPrepTimePicker.text = "PREP TIME*"
        
        titleForPrepTimePicker.snp.makeConstraints { make in
            make.top.equalTo(servingsViewButton.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    private func setupPrepTimePickerViewButton() {
        contentView.addSubview(prepTimeViewButton)
        
        contentView.addSubview(prepTimeLabel)
        prepTimeLabel.text = "Select prep time"
        prepTimeLabel.textColor = .ui.secondaryText
        prepTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(prepTimeViewButton.snp.leading).offset(12) // Adjust the offset as needed
            make.centerY.equalTo(prepTimeViewButton.snp.centerY)
        }
        
        // Configure the button
        prepTimeViewButton.backgroundColor = .ui.primaryContainer
        prepTimeViewButton.layer.cornerRadius = 20
        prepTimeViewButton.addTarget(self, action: #selector(popUpPicker(_:)), for: .touchUpInside)

        // Set constraints for pickerViewButton
        prepTimeViewButton.snp.makeConstraints { make in
            make.top.equalTo(titleForPrepTimePicker.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.greaterThanOrEqualTo(50)
        }
    }
    
    private func setupDivider() {
        contentView.addSubview(divider)
        
        divider.backgroundColor = UIColor.ui.divider
        divider.snp.makeConstraints { make in
            make.top.equalTo(prepTimeViewButton.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(0.5)
        }
    }

    // Ingridients with title
    
    private func setupTitleForIngridients() {
        contentView.addSubview(titleForIngridients)
        titleForIngridients.text = "INGRIDIENTS"
        
        titleForIngridients.snp.makeConstraints { make in
            make.top.equalTo(divider.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }

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
