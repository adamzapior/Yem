//
//  AddRecipeVC.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import Combine
import LifetimeTracker
import SnapKit
import UIKit

final class AddRecipeVC: UIViewController {
    // MARK: - Properties
    
//    let coordinator: AddRecipeCoordinator
    weak var coordinator: AddRecipeCoordinator?
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
   
    private var nameTextfield = TextfieldWithIcon(iconImage: "info.square", placeholderText: "Enter your recipe name*", textColor: .ui.secondaryText)
    private var difficultyPicker = AddPicker(iconImage: "puzzlepiece.extension", textOnButton: "Select difficulty*")
    private var servingPicker = AddPicker(iconImage: "person", textOnButton: "Select servings count*")
    private var prepTimePicker = AddPicker(iconImage: "timer", textOnButton: "Select prep time*")
    private var spicyPicker = AddPicker(iconImage: "leaf", textOnButton: "Select spicy*")
    private var categoryPicker = AddPicker(iconImage: "book", textOnButton: "Select category*")
    
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

     #if DEBUG
        trackLifetime()
     #endif
    }
    
//    init(viewModel: AddRecipeViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//        
//#if DEBUG
//        trackLifetime()
//#endif
//    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Details"
        viewModel.delegateDetails = self
        viewModel.loadDataToEditor()

        setupNavigationBarButtons()
        
        setupScrollView()
        setupContentView()
        
        setupPageStackView()
    
        setupAddPhotoView()
        configureRecipeDataStackView()
        
        setupTag()
        setupDelegate()
        setupDataSource()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        coordinator.coordinatorDidFinish() 4Delete
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
        
    private func setupAddPhotoView() {
        contentView.addSubview(addPhotoView)
    
        addPhotoView.snp.makeConstraints { make in
            make.top.equalTo(pageStackView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(200)
        }
        
        addPhotoView.delegate = self
        
        // picker delegate
        addPhotoImagePicker.delegate = self
        addPhotoImagePicker.allowsEditing = false
        addPhotoImagePicker.mediaTypes = ["public.image"]
    }
    
    private func configureRecipeDataStackView() {
        contentView.addSubview(recipeDataStack)
        recipeDataStack.addArrangedSubview(nameTextfield)
        recipeDataStack.addArrangedSubview(difficultyPicker)
        recipeDataStack.addArrangedSubview(servingPicker)
        recipeDataStack.addArrangedSubview(prepTimePicker)
        recipeDataStack.addArrangedSubview(spicyPicker)
        recipeDataStack.addArrangedSubview(categoryPicker)
        
        recipeDataStack.snp.makeConstraints { make in
            make.top.equalTo(addPhotoView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
        }
    }
    
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
                self.difficultyPicker.textOnButton.text = selectedDifficulty.displayName
                self.difficultyPicker.textOnButton.textColor = .ui.primaryText
                self.viewModel.difficulty = selectedDifficulty.displayName
            case 2:
                
                let selectedServing = self.viewModel.servingRowArray[selectedRow]
                self.servingPicker.textOnButton.text = "\(selectedServing.description) (serving)"
                self.servingPicker.textOnButton.textColor = .ui.primaryText
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
                self.prepTimePicker.textOnButton.text = "\(hours) \(minutes)".trimmingCharacters(in: .whitespaces)
                self.prepTimePicker.textOnButton.textColor = .ui.primaryText

            case 4:
                let selectedSpicy = self.viewModel.spicyRowArray[selectedRow]
                self.spicyPicker.textOnButton.text = selectedSpicy.displayName
                self.spicyPicker.textOnButton.textColor = .ui.primaryText
                self.viewModel.spicy = selectedSpicy.displayName
            case 5:
                let selectedCategory = self.viewModel.categoryRowArray[selectedRow]
                self.categoryPicker.textOnButton.text = selectedCategory.displayName
                self.categoryPicker.textOnButton.textColor = .ui.primaryText
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

extension AddRecipeVC: TextfieldWithIconDelegate, AddPickerDelegate {
    func setupTag() {
        difficultyPicker.tag = 1
        difficultyPickerView.tag = 1
        
        servingPicker.tag = 2
        servingsPickerView.tag = 2

        prepTimePicker.tag = 3
        prepTimePickerView.tag = 3

        spicyPicker.tag = 4
        spicyPickerView.tag = 4

        categoryPicker.tag = 5
        categoryPickerView.tag = 5
    }
    
    func setupDelegate() {
        nameTextfield.delegate = self
        
        servingPicker.delegate = self
        prepTimePicker.delegate = self
        spicyPicker.delegate = self

        difficultyPicker.delegate = self
        difficultyPickerView.delegate = self
        categoryPicker.delegate = self
        categoryPickerView.delegate = self
    }
    
    func setupDataSource() {
        difficultyPickerView.dataSource = self
        categoryPickerView.dataSource = self
    }

    func textFieldDidChange(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        if let text = textfield.textField.text {
            viewModel.recipeTitle = text
        }
    }
    
    func textFieldDidBeginEditing(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        if let text = textfield.textField.text {
            viewModel.recipeTitle = text
        }
    }
    
    func textFieldDidEndEditing(_ textfield: TextfieldWithIcon, didUpdateText text: String) {
        if let text = textfield.textField.text {
            viewModel.recipeTitle = text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Ukrywa klawiaturę
        return true
    }
    
    func pickerTapped(item: AddPicker) {
        switch item.tag {
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
            difficultyPicker.textOnButton.text = selectedDifficulty.displayName
            difficultyPicker.textOnButton.textColor = .ui.primaryText
            viewModel.difficulty = selectedDifficulty.displayName
        case 2:
            let selectedServing = viewModel.servingRowArray[row]
            servingPicker.textOnButton.text = "\(selectedServing.description) (serving)"
            servingPicker.textOnButton.textColor = .ui.primaryText
            viewModel.serving = selectedServing.description
        case 3:
            if component == 0 {
                let selectedHours = viewModel.timeHoursArray[row].description
                viewModel.prepTimeHours = selectedHours
            } else {
                let selectedMinutes = viewModel.timeMinutesArray[row].description
                viewModel.prepTimeMinutes = selectedMinutes
            }
            
            var hours = ""
            var minutes = ""
            
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
            
            prepTimePicker.textOnButton.text = "\(hours) \(minutes)"
            prepTimePicker.textOnButton.textColor = .ui.primaryText
        case 4:
            let selectedSpicy = viewModel.spicyRowArray[row]
            spicyPicker.textOnButton.text = selectedSpicy.displayName
            spicyPicker.textOnButton.textColor = .ui.primaryText
            viewModel.spicy = selectedSpicy.displayName
        case 5:
            let selectedCategory = viewModel.categoryRowArray[row]
            categoryPicker.textOnButton.text = selectedCategory.displayName
            categoryPicker.textOnButton.textColor = .ui.primaryText
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
    func loadDataToEditor() {
        if let image = viewModel.selectedImage {
            addPhotoView.updatePhoto(with: image)
        }
        
        nameTextfield.textField.text = viewModel.recipeTitle
        
        servingPicker.textOnButton.text = "\(viewModel.serving) (serving)"
        servingPicker.textOnButton.textColor = .ui.primaryText
        
        difficultyPicker.textOnButton.text = viewModel.difficulty
        difficultyPicker.textOnButton.textColor = .ui.primaryText
        
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
        prepTimePicker.textOnButton.text = "\(hours) \(minutes)".trimmingCharacters(in: .whitespaces)
        prepTimePicker.textOnButton.textColor = .ui.primaryText
        
        spicyPicker.textOnButton.text = viewModel.spicy
        spicyPicker.textOnButton.textColor = .ui.primaryText
        
        categoryPicker.textOnButton.text = viewModel.category
        categoryPicker.textOnButton.textColor = .ui.primaryText
    }
    
    func delegateDetailsError(_ type: ValidationErrorTypes) {
        switch type {
        case .recipeTitle:
            nameTextfield.setPlaceholderColor(.ui.placeholderError)
        case .servings:
            servingPicker.setPlaceholderColor(.ui.placeholderError)
        case .difficulty:
            difficultyPicker.setPlaceholderColor(.ui.placeholderError)
        case .prepTime:
            prepTimePicker.setPlaceholderColor(.ui.placeholderError)
        case .spicy:
            spicyPicker.setPlaceholderColor(.ui.placeholderError)
        case .category:
            categoryPicker.setPlaceholderColor(.ui.placeholderError)
        case .ingredientName:
            break
        case .ingredientValue:
            break
        case .ingredientValueType:
            break
        case .instruction:
            break
        case .ingredientList:
            break
        case .instructionList:
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
//        coordinator.pushVC(for: .ingredientsList)
    }
}

#if DEBUG
extension AddRecipeVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
