//
//  CookingModeVC.swift
//  Yem
//
//  Created by Adam Zapiór on 17/08/2024.
//

import Combine
import LifetimeTracker
import SnapKit
import UIKit

class CookingModeViewController: UIViewController {
    let viewModel: CookingModeViewModel
    weak var coordinator: CookingModeCoordinator?
    var recipe: RecipeModel

    private var pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    private var pageControl = UIPageControl()

    private let stepsLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .bold,
        textColor: .secondaryText
    )

    private let timerLabel = TextLabel(
        fontStyle: .body,
        fontWeight: .regular,
        textColor: .primaryText
    )

    lazy var exitNavItem = UIBarButtonItem(
        image: UIImage(systemName: "chevron.backward"),
        style: .plain,
        target: self,
        action: #selector(backButtonTapped)
    )

    lazy var timerNavItem = UIBarButtonItem(
        image: UIImage(systemName: "timer"),
        style: .plain,
        target: self,
        action: #selector(timerButtonTapped)
    )

    lazy var ingredientNavItem = UIBarButtonItem(
        image: UIImage(systemName: "list.bullet"),
        style: .plain,
        target: self,
        action: #selector(ingredientsButtonTapped)
    )

    lazy var leftArrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .ui.theme
        button.layer.cornerRadius = 32.VAdapted // Half of button height from setup method
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(leftArrowButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    lazy var rightArrowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .ui.theme
        button.layer.cornerRadius = 32.VAdapted // Half of button height from setup method
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor // Dodanie cienia
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(rightArrowButtonTapped), for: .touchUpInside)
        return button
    }()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    init(
        viewModel: CookingModeViewModel,
        coordinator: CookingModeCoordinator,
        recipe: RecipeModel
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.recipe = recipe
        super.init(nibName: nil, bundle: nil)

        #if DEBUG
            trackLifetime()
        #endif
    }

    deinit {
        NotificationCenter.default.removeObserver(self)

        coordinator?.navigator?.navigationController.interactivePopGestureRecognizer?.isEnabled = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        viewModel.delegate = self

        recipe.sortInstructionsByIndex()

        setupNavigationBarButtons()
        setupStepsLabel()
        setupTimerLabel()
        setupPageViewController()
        setupPageControl()
        setupArrowButtons() // Setup arrow buttons
        updateArrowButtonsVisibility() // Initial visibility update
        updateStepsLabel()

        coordinator?.navigator?.navigationController.interactivePopGestureRecognizer?.isEnabled = false
    }

    // MARK: - UI Setup

    private func setupTimerLabel() {
        view.addSubview(timerLabel)

        timerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.trailing.equalToSuperview().inset(32)
        }

        timerLabel.text = ""

        viewModel.$timeRemaining
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeRemaining in
                self?.timerLabel.text = timeRemaining
            }
            .store(in: &cancellables)
    }

    private func setupStepsLabel() {
        view.addSubview(stepsLabel)
        stepsLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.equalToSuperview().inset(32)
        }
    }

    private func updateStepsLabel() {
        let currentStep = pageControl.currentPage + 1
        stepsLabel.text = "STEP \(currentStep)"
    }

    private func setupPageViewController() {
        pageViewController.dataSource = self
        pageViewController.delegate = self

        if let firstViewController = viewControllerAtIndex(0) {
            pageViewController.setViewControllers(
                [firstViewController],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

        pageViewController.view.snp.makeConstraints { make in
            make.top.equalTo(stepsLabel.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(240)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func setupPageControl() {
        pageControl.numberOfPages = recipe.instructionList.count
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        view.addSubview(pageControl)

        pageControl.snp.makeConstraints { make in
            make.top.equalTo(pageViewController.view.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
    }

    private func setupArrowButtons() {
        view.addSubview(leftArrowButton)
        view.addSubview(rightArrowButton)

        leftArrowButton.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(24)
            make.leading.equalTo(view.snp.leading).offset(32)
            make.width.height.equalTo(64.VAdapted)
        }

        rightArrowButton.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(24)
            make.trailing.equalTo(view.snp.trailing).inset(32)
            make.width.height.equalTo(64.VAdapted)
        }
    }

    // Update arrow buttons visibility based on the current page index
    private func updateArrowButtonsVisibility() {
        let currentPage = pageControl.currentPage
        let isFirstPage = currentPage == 0
        let isLastPage = currentPage == pageControl.numberOfPages - 1

        // Left button
        if isFirstPage {
            if !leftArrowButton.isHidden {
                leftArrowButton.animateFadeOut()
            }
        } else {
            if leftArrowButton.isHidden {
                leftArrowButton.isHidden = false
                leftArrowButton.animateFadeIn()
            }
        }

        // Right button
        if isLastPage {
            if !rightArrowButton.isHidden {
                rightArrowButton.animateFadeOut()
            }
        } else {
            if rightArrowButton.isHidden {
                rightArrowButton.isHidden = false
                rightArrowButton.animateFadeIn()
            }
        }
    }

    private func viewControllerAtIndex(_ index: Int) -> UIViewController? {
        guard index >= 0 && index < recipe.instructionList.count else { return nil }

        let instructionViewController = CookingInstructionVC(
            instruction: recipe.instructionList[index],
            ingredients: recipe.ingredientList
        )
        instructionViewController.pageIndex = index
        return instructionViewController
    }

    // MARK: Page controll methods

    @objc func pageControlTapped(_ sender: UIPageControl) {
        let currentIndex = sender.currentPage
        if let viewController = viewControllerAtIndex(currentIndex) {
            let direction: UIPageViewController.NavigationDirection = currentIndex > pageControl.currentPage ? .forward : .reverse
            pageViewController.setViewControllers(
                [viewController],
                direction: direction,
                animated: true,
                completion: nil
            )
        }
        updateArrowButtonsVisibility() // Update visibility after changing page
        updateStepsLabel()
    }

    @objc func leftArrowButtonTapped() {
        let currentIndex = pageControl.currentPage
        let previousIndex = max(currentIndex - 1, 0)
        pageControl.currentPage = previousIndex
        if let viewController = viewControllerAtIndex(previousIndex) {
            pageViewController.setViewControllers(
                [viewController],
                direction: .reverse,
                animated: true,
                completion: nil
            )
        }
        updateArrowButtonsVisibility() // Update visibility after changing page
        updateStepsLabel()
    }

    @objc func rightArrowButtonTapped() {
        let currentIndex = pageControl.currentPage
        let nextIndex = min(currentIndex + 1, pageControl.numberOfPages - 1)
        pageControl.currentPage = nextIndex
        if let viewController = viewControllerAtIndex(nextIndex) {
            pageViewController.setViewControllers(
                [viewController],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
        updateArrowButtonsVisibility() // Update visibility after changing page
        updateStepsLabel()
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate

extension CookingModeViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? CookingInstructionVC else { return nil }
        var index = viewController.pageIndex
        index -= 1
        return viewControllerAtIndex(index)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? CookingInstructionVC else { return nil }
        var index = viewController.pageIndex
        index += 1
        return viewControllerAtIndex(index)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed, let viewController = pageViewController.viewControllers?.first as? CookingInstructionVC {
            pageControl.currentPage = viewController.pageIndex

            updateStepsLabel()
            updateArrowButtonsVisibility()
        }
    }
}

// MARK: - Navigation bar

extension CookingModeViewController {
    func setupNavigationBarButtons() {
        navigationItem.setRightBarButtonItems(
            [
                ingredientNavItem,
                timerNavItem
            ],
            animated: true
        )

        navigationItem.leftBarButtonItem = exitNavItem
    }

    @objc func backButtonTapped() {
        coordinator?.presentExitAlert()
    }

    @objc func ingredientsButtonTapped(_ sender: UIBarButtonItem) {
        coordinator?.openIngredientsSheet()
    }

    @objc func timerButtonTapped(_ sender: UIBarButtonItem) {
        coordinator?.openTimeSheet()
    }
}

// MARK: - Delegates

extension CookingModeViewController: CookingModeVCDelegate {
    func timerStarted() {
        if let timerButtonView = timerNavItem.value(forKey: "view") as? UIView {
            timerButtonView.startShaking()
            print("Timer started delegate")
        }
    }

    func timerStopped() {
        coordinator?.presentTimerStoppedAlert()
        if let timerButtonView = timerNavItem.value(forKey: "view") as? UIView {
            timerButtonView.stopShaking()
            print("Timer started delegate")
        }
    }
}

#if DEBUG
    extension CookingModeViewController: LifetimeTrackable {
        class var lifetimeConfiguration: LifetimeConfiguration {
            return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
        }
    }
#endif
