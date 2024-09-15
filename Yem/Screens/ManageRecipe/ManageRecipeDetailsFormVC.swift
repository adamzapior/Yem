//
//  AddRecipeVC.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import Combine
import CombineCocoa
import LifetimeTracker
import SnapKit
import UIKit

import AVFoundation
import Photos
import PhotosUI

final class ManageRecipeDetailsFromVC: UIViewController {
    private weak var coordinator: ManageRecipeCoordinator?
    private let viewModel: ManageRecipeVM
    
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
    
    private var nameTextfield = TextfieldWithIcon(
        iconImage: "info.square",
        placeholderText: "Enter recipe name*",
        textColor: .ui.secondaryText
    )
    private var difficultyPickerView = AddPickerView(
        iconImage: "puzzlepiece.extension",
        textOnButton: "Select difficulty level*"
    )
    private var servingPickerView = AddPickerView(
        iconImage: "person",
        textOnButton: "Select servings count*"
    )
    private var prepTimePickerView = AddPickerView(
        iconImage: "timer",
        textOnButton: "Select prep time*"
    )
    private var spicyPickerView = AddPickerView(
        iconImage: "leaf",
        textOnButton: "Select spicy level*"
    )
    private var categoryPickerView = AddPickerView(
        iconImage: "book",
        textOnButton: "Select recipe category*"
    )
    
    private let recipeDataStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()
    
    private lazy var difficultyPicker = UIPickerView()
    private lazy var servingsPicker = UIPickerView()
    private lazy var prepTimePicker = UIPickerView()
    private lazy var spicyPicker = UIPickerView()
    private lazy var categoryPicker = UIPickerView()
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    
    init(coordinator: ManageRecipeCoordinator, viewModel: ManageRecipeVM) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
#if DEBUG
        trackLifetime()
#endif
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Details"
        
        setupNavigationBarButtons()
        setupScrollView()
        setupContentView()
        setupPageStackView()
        setupAddPhotoView()
        
        setupPickerViews()

        setupRecipeDataStack()
        setupAnimations()
        setupVoiceOverAccessibility()
        hideKeyboardWhenTappedAround()
        
        observeViewModelOutput()
        observePhotoView()
        observeTextfield()
        observeValuePickers()
        
        viewModel.inputDetailsFormEvent.send(.viewDidLoad)
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
            make.height.equalTo(200.VAdapted)
        }
                
        // picker delegate
        addPhotoImagePicker.delegate = self
        addPhotoImagePicker.allowsEditing = false
        addPhotoImagePicker.mediaTypes = ["public.image"]
    }
    
    private func loadPhotoView(image: UIImage) {
        addPhotoView.updatePhoto(with: image)
    }
    
    private func setupRecipeDataStack() {
        contentView.addSubview(recipeDataStack)
        recipeDataStack.addArrangedSubview(nameTextfield)
        recipeDataStack.addArrangedSubview(difficultyPickerView)
        recipeDataStack.addArrangedSubview(servingPickerView)
        recipeDataStack.addArrangedSubview(prepTimePickerView)
        recipeDataStack.addArrangedSubview(spicyPickerView)
        recipeDataStack.addArrangedSubview(categoryPickerView)
        
        recipeDataStack.snp.makeConstraints { make in
            make.top.equalTo(addPhotoView.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(18)
        }
    }
    
    private func setupPickerViews() {
        difficultyPicker.tag = 1
        servingsPicker.tag = 2
        prepTimePicker.tag = 3
        spicyPicker.tag = 4
        categoryPicker.tag = 5
            
        difficultyPicker.delegate = self
        servingsPicker.delegate = self
        prepTimePicker.delegate = self
        spicyPicker.delegate = self
        categoryPicker.delegate = self
            
        difficultyPicker.dataSource = self
        servingsPicker.dataSource = self
        prepTimePicker.dataSource = self
        spicyPicker.dataSource = self
        categoryPicker.dataSource = self
    }
    
    private func setupAnimations() {
        addPhotoView.animateFadeIn()
        nameTextfield.animateFadeIn()
        difficultyPickerView.animateFadeIn()
        servingPickerView.animateFadeIn()
        prepTimePickerView.animateFadeIn()
        spicyPickerView.animateFadeIn()
        categoryPickerView.animateFadeIn()
    }
    
    private func setupVoiceOverAccessibility() {
        addPhotoView.isAccessibilityElement = true
        addPhotoView.accessibilityLabel = "Photo view"
        addPhotoView.accessibilityHint = "Click to add photo of your recipe"
        
        nameTextfield.isAccessibilityElement = true
        nameTextfield.accessibilityLabel = "Name textfield"
        nameTextfield.accessibilityHint = "Enter recipe name"
        
        difficultyPickerView.isAccessibilityElement = true
        difficultyPickerView.accessibilityLabel = "Difficulty picker"
        difficultyPickerView.accessibilityHint = "Select difficulty level"
        
        servingPickerView.isAccessibilityElement = true
        servingPickerView.accessibilityLabel = "Serving picker"
        servingPickerView.accessibilityHint = "Select serving"
        
        prepTimePickerView.isAccessibilityElement = true
        prepTimePickerView.accessibilityLabel = "Prep time picker"
        prepTimePickerView.accessibilityHint = "Enter preparation time"
        
        spicyPickerView.isAccessibilityElement = true
        spicyPickerView.accessibilityLabel = "Spicy picker"
        spicyPickerView.accessibilityHint = "Select spicy level"
        
        categoryPickerView.isAccessibilityElement = true
        categoryPickerView.accessibilityLabel = "Category picker"
        categoryPickerView.accessibilityHint = "Select recipe category"
    }
}

// MARK: - Observed ViewModel Output & UI actions

extension ManageRecipeDetailsFromVC {
    private func observeViewModelOutput() {
        viewModel.outputDetailsFormEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] event in
                handleViewModelOutput(for: event)
            }
            .store(in: &cancellables)
    }
    
    private func observePhotoView() {
        addPhotoView
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                self.handleAddPhotoViewTapped()
            }
            .store(in: &cancellables)
    }
    
    private func observeTextfield() {
        nameTextfield.textField
            .textPublisher
            .dropFirst() /* when the recipe exists, creating a publisher sends an empty value to the ViewModel, 
                          which overwrites the set value - it is necessary to ignore the first value  */
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] text in
                self.viewModel.inputDetailsFormEvent.send(
                    .sendDetailsValues(
                        .recipeTitle(text ?? "")))
            }
            .store(in: &cancellables)
    }
    
    private func observeValuePickers() {
        difficultyPickerView
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] in
                self.popUpPicker(for: difficultyPicker, title: "Select difficulty level")
            }
            .store(in: &cancellables)
        
        servingPickerView
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                popUpPicker(for: servingsPicker, title: "Select servings count")
            }
            .store(in: &cancellables)
        
        prepTimePickerView
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.popUpPicker(for: prepTimePicker, title: "Select time prep")
            }
            .store(in: &cancellables)
        
        spicyPickerView
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.popUpPicker(for: spicyPicker, title: "Select spicy level")
            }
            .store(in: &cancellables)
        
        categoryPickerView
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.popUpPicker(for: categoryPicker, title: "Select recipe category")
            }
            .store(in: &cancellables)
    }
}

// MARK: - Handle Output & UI Actions

extension ManageRecipeDetailsFromVC {
    private func handleViewModelOutput(for event: ManageRecipeVM.DetailsFormOutput) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch event {
            case .updateImage(let image):
                loadPhotoView(image: image)
            case .updateDetailsField(let field):
                handleDetailsFieldOutput(for: field)
                handleUpdateAccessibility(for: field)
            case .validationError(let error):
                handleDetailsError(for: error)
            case .openPhotoLibrary:
                presentPHPicker()
            case .openCamera:
                presentImagePicker(sourceType: .camera)
            }
        }
    }
    
    private func handleDetailsFieldOutput(for field: ManageRecipeVM.Details) {
        switch field {
        case .recipeTitle(let value):
            nameTextfield.textField.text = value
        case .difficulty(let value):
            difficultyPickerView.textOnButton.text = value
            difficultyPickerView.textOnButton.textColor = .ui.primaryText
        case .servings(let value):
            servingPickerView.textOnButton.text = value
            servingPickerView.textOnButton.textColor = .ui.primaryText
        case .prepTime(.hours(_)):
            break
        case .prepTime(.minutes(_)):
            break
        case .prepTime(.fullTime(let value)):
            prepTimePickerView.textOnButton.text = value
            prepTimePickerView.textOnButton.textColor = .ui.primaryText
        case .spicy(let value):
            spicyPickerView.textOnButton.text = value
            spicyPickerView.textOnButton.textColor = .ui.primaryText
        case .category(let value):
            categoryPickerView.textOnButton.text = value
            categoryPickerView.textOnButton.textColor = .ui.primaryText
        }
    }
        
    private func handleUpdateAccessibility(
        for element: ManageRecipeVM.Details
    ) {
        switch element {
        case .recipeTitle(let value):
            nameTextfield.accessibilityValue = value
            nameTextfield.accessibilityHint = value.isEmpty ? "Enter recipe name" : nil
        case .difficulty(let value):
            difficultyPickerView.accessibilityValue = value
            difficultyPickerView.accessibilityHint = value.isEmpty ? "Select difficulty level" : nil
        case .servings(let value):
            servingPickerView.accessibilityValue = value
            servingPickerView.accessibilityHint = value.isEmpty ? "Select serving" : nil
        case .prepTime(let type):
            if case .fullTime(let value) = type {
                prepTimePickerView.accessibilityValue = value
                prepTimePickerView.accessibilityHint = value.isEmpty ? "Select prep time" : nil
            }
        case .spicy(let value):
            spicyPickerView.accessibilityValue = value
            spicyPickerView.accessibilityHint = value.isEmpty ? "Select difficulty level" : nil
        case .category(let value):
            categoryPickerView.accessibilityValue = value
            difficultyPickerView.accessibilityHint = value.isEmpty ? "Select difficulty level" : nil
        }
    }
    
    func handleDetailsError(for errorType: ManageRecipeVM.ErrorType.Details) {
        switch errorType {
        case .recipeTitle:
            nameTextfield.setPlaceholderColor(.ui.placeholderError)
        case .servings:
            servingPickerView.setPlaceholderColor(.ui.placeholderError)
        case .difficulty:
            difficultyPickerView.setPlaceholderColor(.ui.placeholderError)
        case .prepTime:
            prepTimePickerView.setPlaceholderColor(.ui.placeholderError)
        case .spicy:
            spicyPickerView.setPlaceholderColor(.ui.placeholderError)
        case .category:
            categoryPickerView.setPlaceholderColor(.ui.placeholderError)
        }
    }
    
    // MARK: Tap actions
    
    func handleAddPhotoViewTapped() {
        let actionSheet = UIAlertController(title: "Select source", message: "", preferredStyle: .actionSheet)
        actionSheet.view.tintColor = .orange
            
        let chooseFromLibraryAction = UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.viewModel.inputDetailsFormEvent.send(.requestPhotoLibrary)
        }
            
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.viewModel.inputDetailsFormEvent.send(.requestCamera)
        }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
        actionSheet.addAction(chooseFromLibraryAction)
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(cancelAction)
            
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ManageRecipeDetailsFromVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        let itemProviders = results.map(\.itemProvider)
        for item in itemProviders {
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self.viewModel.selectedImage = image
                        }
                    }
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

/// Picker to handle camera
    
extension ManageRecipeDetailsFromVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.selectedImage = image
            addPhotoView.updatePhoto(with: image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - PHPicker

extension ManageRecipeDetailsFromVC {
    private func presentPHPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1 
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            let alert = UIAlertController(title: "Error", message: "This feature is not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        addPhotoImagePicker.sourceType = sourceType
        present(addPhotoImagePicker, animated: true, completion: nil)
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource

extension ManageRecipeDetailsFromVC: UIPickerViewDataSource {
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
}
    
extension ManageRecipeDetailsFromVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let reuseLabel = view as? UILabel {
            label = reuseLabel
        } else {
            label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
            label.textAlignment = .center
        }
            
        label.font = UIFont.preferredFont(forTextStyle: .body)
            
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
        case 1:
            let selectedDifficulty = viewModel.difficultyRowArray[row].displayName
            viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.difficulty(selectedDifficulty)))
        case 2:
            let selectedServing = viewModel.servingRowArray[row]
            viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.servings(selectedServing.formatted())))
        case 3:
            switch component {
            case 0:
                let selectedHours = viewModel.timeHoursArray[row]
                viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.prepTime(.hours(selectedHours.formatted()))))
            case 1:
                let selectedMinutes = viewModel.timeMinutesArray[row]
                viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.prepTime(.minutes(selectedMinutes.formatted()))))
            default:
                break
            }
        case 4:
            let selectedSpicy = viewModel.spicyRowArray[row].displayName
            viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.spicy(selectedSpicy)))
        case 5:
            let selectedCategory = viewModel.categoryRowArray[row].displayName
            viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.category(selectedCategory)))
        default:
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60.VAdapted
    }
}

// MARK: UIPicker helper methods

extension ManageRecipeDetailsFromVC {
    private func popUpPicker(for pickerView: UIPickerView, title: String) {
        view.endEditing(true)
            
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.tag = pickerView.tag
            
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: view.frame.width - 20, height: 180.VAdapted)
        pickerView.frame = CGRect(x: 0, y: 0, width: vc.preferredContentSize.width, height: 180.VAdapted)
        vc.view.addSubview(pickerView)
            
        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.setValue(vc, forKey: "contentViewController")
            
        let selectAction = UIAlertAction(title: "Select", style: .default, handler: {
            _ in
            let selectedRow = pickerView.selectedRow(inComponent: 0)
                
            switch pickerView.tag {
            case 1:
                let selectedDifficulty = self.viewModel.difficultyRowArray[selectedRow].displayName
                self.viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.difficulty(selectedDifficulty)))
                    
            case 2:
                    
                let selectedServing = self.viewModel.servingRowArray[selectedRow]
                self.viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.servings(selectedServing.formatted())))
            case 3:
                
                let selectedHoursRow = pickerView.selectedRow(inComponent: 0)
                let selectedMinutesRow = pickerView.selectedRow(inComponent: 1)
                       
                self.viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.prepTime(.hours(selectedHoursRow.formatted()))))
                
                self.viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.prepTime(.minutes(selectedMinutesRow.formatted()))))

            case 4:
                let selectedSpicy = self.viewModel.spicyRowArray[selectedRow].displayName
                self.viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.spicy(selectedSpicy)))
            case 5:
                let selectedCategory = self.viewModel.categoryRowArray[selectedRow].displayName
                self.viewModel.inputDetailsFormEvent.send(.sendDetailsValues(.category(selectedCategory)))
            default:
                break
            }
                
        })
            
        selectAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(selectAction)
        present(alert, animated: true, completion: nil)
    }
}
    
// MARK: - Navigation Items + Navigation
    
extension ManageRecipeDetailsFromVC {
    func setupNavigationBarButtons() {
        let nextButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonTapped))
        navigationItem.rightBarButtonItem = nextButtonItem
    }
        
    @objc func nextButtonTapped(_ sender: UIBarButtonItem) {
        coordinator?.navigateTo(.ingredientsList)
    }
}

// MARK: - LifetimeTrackable
    
#if DEBUG
extension ManageRecipeDetailsFromVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
