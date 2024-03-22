//
//  AddRecipeVC.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import Combine
import SnapKit
import UIKit

final class AddRecipeVC: UIViewController {
    // MARK: - Properties
    
    let coordinator: AddRecipeCoordinator
    let viewModel: AddRecipeViewModel
    
    // MARK: - View properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let pageStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 4
        return sv
    }()
    
    private let pageCount = 3
    private var pageViews = [UIView]()
    
    private let screenWidth = UIScreen.main.bounds.width - 10
    private let screenHeight = UIScreen.main.bounds.height / 2
    
    private let addPhotoView = PhotoView()
    private let addPhotoImagePicker = UIImagePickerController()
   
    private var nameTextfield = TextfieldWithIconRow(iconImage: "info.square", placeholderText: "Enter your recipe name*", textColor: .ui.secondaryText)
    private var difficultyCell = PickerWithIconRow(iconImage: "puzzlepiece.extension", textOnButton: "Select difficulty*")
    private var servingCell = PickerWithIconRow(iconImage: "person", textOnButton: "Select servings count*")
    private var prepTimeCell = PickerWithIconRow(iconImage: "timer", textOnButton: "Select prep time*")
    private var spicyCell = PickerWithIconRow(iconImage: "leaf", textOnButton: "Select spicy*")
    private var categoryCell = PickerWithIconRow(iconImage: "book", textOnButton: "Select category*")
    
    private lazy var difficultyPickerView = UIPickerView()
    private lazy var servingsPickerView = UIPickerView()
    private lazy var prepTimePickerView = UIPickerView()
    private lazy var spicyPickerView = UIPickerView()
    private lazy var categoryPickerView = UIPickerView()
    
    private let recipeDataStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()
    
    // MARK: - Lifecycle
    
    init(coordinator: AddRecipeCoordinator, viewModel: AddRecipeViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Details"
        viewModel.delegateDetails = self
        viewModel.loadData()

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
            make.leading.trailing.equalToSuperview()
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
    
    // MARK: - Pop Up Picker method

    private func popUpPicker(for pickerView: UIPickerView, title: String) {
        view.endEditing(true)
        
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.tag = pickerView.tag

        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: view.frame.width - 20, height: 180)
        pickerView.frame = CGRect(x: 0, y: 0, width: vc.preferredContentSize.width, height: 180)
        vc.view.addSubview(pickerView)

        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.setValue(vc, forKey: "contentViewController")

        let selectAction = UIAlertAction(title: "Select", style: .default, handler: { _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
                   
            switch pickerView.tag {
            case 1:
                let selectedDifficulty = self.viewModel.difficultyRowArray[selectedRow]
                self.difficultyCell.textOnButton.text = selectedDifficulty.displayName
                self.difficultyCell.textOnButton.textColor = .ui.primaryText
                self.viewModel.difficulty = selectedDifficulty.displayName
            case 2:
                
                let selectedServing = self.viewModel.servingRowArray[selectedRow]
                self.servingCell.textOnButton.text = "\(selectedServing.description) (serving)"
                self.servingCell.textOnButton.textColor = .ui.primaryText
                self.viewModel.serving = selectedServing.description
                
            case 3:
                let selectedHoursRow = pickerView.selectedRow(inComponent: 0)
                let selectedMinutesRow = pickerView.selectedRow(inComponent: 1)

                let selectedHours = self.viewModel.timeHoursArray[selectedHoursRow].description
                self.viewModel.prepTimeHours = selectedHours

                let selectedMinutes = self.viewModel.timeMinutesArray[selectedMinutesRow].description
                self.viewModel.prepTimeMinutes = selectedMinutes

                var hours = ""
                var minutes = ""
                
                if self.viewModel.prepTimeHours != "0", self.viewModel.prepTimeHours != "1", self.viewModel.prepTimeHours != "" {
                    hours = "\(self.viewModel.prepTimeHours) hours"
                } else if self.viewModel.prepTimeHours == "1" {
                    hours = "\(self.viewModel.prepTimeHours) hour"
                }

                if self.viewModel.prepTimeMinutes != "0", self.viewModel.prepTimeMinutes != "" {
                    minutes = "\(self.viewModel.prepTimeMinutes) min"
                }
                self.prepTimeCell.textOnButton.text = "\(hours) \(minutes)".trimmingCharacters(in: .whitespaces)
                self.prepTimeCell.textOnButton.textColor = .ui.primaryText

            case 4:
                let selectedSpicy = self.viewModel.spicyRowArray[selectedRow]
                self.spicyCell.textOnButton.text = selectedSpicy.displayName
                self.spicyCell.textOnButton.textColor = .ui.primaryText
                self.viewModel.spicy = selectedSpicy.displayName
            case 5:
                let selectedCategory = self.viewModel.categoryRowArray[selectedRow]
                self.categoryCell.textOnButton.text = selectedCategory.displayName
                self.categoryCell.textOnButton.textColor = .ui.primaryText
                self.viewModel.category = selectedCategory.displayName
            default:
                break
            }
            
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
        setupAddPhotoPicker()
        setupNameTextfield()
        setupDifficultyCell()
        setupServingCell()
        setupPrepTimeCell()
        setupSpicyCell()
        setupCategoryCell()
    }
    
    private func setupAddPhotoPicker() {
        addPhotoView.delegate = self
        
        // picker delegate
        addPhotoImagePicker.delegate = self
        addPhotoImagePicker.allowsEditing = false
        addPhotoImagePicker.mediaTypes = ["public.image"]
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

// MARK: - AddPhotoView delegate

extension AddRecipeVC: AddPhotoViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func addPhotoViewTapped() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.present(self.addPhotoImagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.selectedImage = image
            addPhotoView.updatePhoto(with: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Textfield delegate

extension AddRecipeVC: TextfieldWithIconRowDelegate {
    func textFieldDidChange(_ textfield: TextfieldWithIconRow, didUpdateText text: String) {
        if let text = textfield.textField.text {
            viewModel.recipeTitle = text
        }
    }
    
    func textFieldDidBeginEditing(_ textfield: TextfieldWithIconRow, didUpdateText text: String) {
        if let text = textfield.textField.text {
            viewModel.recipeTitle = text
        }
    }
    
    func textFieldDidEndEditing(_ textfield: TextfieldWithIconRow, didUpdateText text: String) {
        if let text = textfield.textField.text {
            viewModel.recipeTitle = text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Ukrywa klawiaturę
        return true
    }
}

// MARK: - Button delegate/dataSource

extension AddRecipeVC: PickerWithIconRowDelegate {
    func pickerWithIconRowTappped(_ cell: PickerWithIconRow) {
        switch cell.tag {
        case 1:
            popUpPicker(for: difficultyPickerView, title: "Select difficulty")
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
            label.textAlignment = .center
        }
        switch pickerView.tag {
        case 1:
            label.text = viewModel.difficultyRowArray[row].displayName
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
            label.text = viewModel.spicyRowArray[row].displayName
        case 5:
            label.text = viewModel.categoryRowArray[row].displayName
        default:
            label.text = ""
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1: // For difficulty
            let selectedDifficulty = viewModel.difficultyRowArray[row]
            difficultyCell.textOnButton.text = selectedDifficulty.displayName
            difficultyCell.textOnButton.textColor = .ui.primaryText
            viewModel.difficulty = selectedDifficulty.displayName
        case 2:
            let selectedServing = viewModel.servingRowArray[row]
            servingCell.textOnButton.text = "\(selectedServing.description) (serving)"
            servingCell.textOnButton.textColor = .ui.primaryText
            viewModel.serving = selectedServing.description
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
                viewModel.prepTimeHours != ""
            {
                hours = "\(viewModel.prepTimeHours) hours"
            }
            
            /// hours for '1'
            if viewModel.prepTimeHours == "1" {
                hours = "\(viewModel.prepTimeHours) hour"
            }
            
            /// minutes
            if viewModel.prepTimeMinutes != "0" &&
                viewModel.prepTimeMinutes != ""
            {
                minutes = "\(viewModel.prepTimeMinutes) min"
            }
            
            prepTimeCell.textOnButton.text = "\(hours) \(minutes)"
            prepTimeCell.textOnButton.textColor = .ui.primaryText
        case 4:
            let selectedSpicy = viewModel.spicyRowArray[row]
            spicyCell.textOnButton.text = selectedSpicy.displayName
            spicyCell.textOnButton.textColor = .ui.primaryText
            viewModel.spicy = selectedSpicy.displayName
        case 5:
            let selectedCategory = viewModel.categoryRowArray[row]
            categoryCell.textOnButton.text = selectedCategory.displayName
            categoryCell.textOnButton.textColor = .ui.primaryText
            viewModel.category = selectedCategory.displayName
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

extension AddRecipeVC: AddRecipeVCDelegate {
    func loadData() {
        if let image = viewModel.selectedImage {
            addPhotoView.updatePhoto(with: image)
        }
        
        nameTextfield.textField.text = viewModel.recipeTitle
        
        servingCell.textOnButton.text = "\(viewModel.serving) (serving)"
        servingCell.textOnButton.textColor = .ui.primaryText
        
        difficultyCell.textOnButton.text = viewModel.difficulty
        difficultyCell.textOnButton.textColor = .ui.primaryText
        
        /// prep time cell
        var hours = ""
        var minutes = ""
        
        if viewModel.prepTimeHours != "0", viewModel.prepTimeHours != "1", viewModel.prepTimeHours != "" {
            hours = "\(viewModel.prepTimeHours) hours"
        } else if viewModel.prepTimeHours == "1" {
            hours = "\(viewModel.prepTimeHours) hour"
        }

        if viewModel.prepTimeMinutes != "0", viewModel.prepTimeMinutes != "" {
            minutes = "\(viewModel.prepTimeMinutes) min"
        }
        prepTimeCell.textOnButton.text = "\(hours) \(minutes)".trimmingCharacters(in: .whitespaces)
        prepTimeCell.textOnButton.textColor = .ui.primaryText
        
        spicyCell.textOnButton.text = viewModel.spicy
        spicyCell.textOnButton.textColor = .ui.primaryText
        
        categoryCell.textOnButton.text = viewModel.category
        categoryCell.textOnButton.textColor = .ui.primaryText
    }
    
    func delegateDetailsError(_ type: ValidationErrorTypes) {
        switch type {
        case .recipeTitle:
            nameTextfield.setPlaceholderColor(.ui.placeholderError.unsafelyUnwrapped)
        case .servings:
            servingCell.setPlaceholderColor(.ui.placeholderError.unsafelyUnwrapped)
        case .difficulty:
            difficultyCell.setPlaceholderColor(.ui.placeholderError.unsafelyUnwrapped)
        case .prepTime:
            prepTimeCell.setPlaceholderColor(.ui.placeholderError.unsafelyUnwrapped)
        case .spicy:
            spicyCell.setPlaceholderColor(.ui.placeholderError.unsafelyUnwrapped)
        case .category:
            categoryCell.setPlaceholderColor(.ui.placeholderError.unsafelyUnwrapped)
        case .ingredientName:
            break
        case .ingredientValue:
            break
        case .ingredientValueType:
            break
        case .instruction:
            break
        }
    }
}

// MARK: - Navigation

extension AddRecipeVC {
    func setupNavigationBarButtons() {
        let nextButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonTapped))
        navigationItem.rightBarButtonItem = nextButtonItem
    }

    @objc func nextButtonTapped(_ sender: UIBarButtonItem) {
        coordinator.pushVC(for: .ingredientsList)
    }
}
