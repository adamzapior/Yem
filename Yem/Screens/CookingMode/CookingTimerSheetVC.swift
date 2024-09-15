//
//  TimerSheetVC.swift
//  Yem
//
//  Created by Adam Zapiór on 19/08/2024.
//

import Combine
import CombineCocoa
import LifetimeTracker
import SnapKit
import UIKit

class CookingTimerSheetVC: UIViewController {
    weak var coordinator: CookingModeCoordinator?
    private let viewModel: CookingModeViewModel

    private let pickerView = UIPickerView()

    private let timerButton = ActionButton(
        title: "Set timer",
        backgroundColor: .addBackground,
        isShadownOn: true
    )

    private var cancellables = Set<AnyCancellable>()

    init(
        coordinator: CookingModeCoordinator? = nil,
        viewModel: CookingModeViewModel
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

#if DEBUG
        trackLifetime()
#endif
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupPickerView()
        setTimerButton()
        setupSheet()

        viewModel.clearPickerVariables()

        observeViewModelOuput()
        observeActionButton()
    }

    private func setupSheet() {
        let contentHeight = calculateContentHeight()
        let customDetentId = UISheetPresentationController.Detent.Identifier("customDetent")
        let contentDetent = UISheetPresentationController.Detent.custom(identifier: customDetentId) { _ in
            contentHeight
        }

        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [contentDetent]
            presentationController.prefersGrabberVisible = true
        }
    }

    private func calculateContentHeight() -> CGFloat {
        let marginsAndSpacings: CGFloat = 24
        let width = UIScreen.main.bounds.width - 24
        let size = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)

        let elementHeights: CGFloat = [
            pickerView.systemLayoutSizeFitting(size).height,
            timerButton.systemLayoutSizeFitting(size).height
        ].reduce(0, +)

        return elementHeights + marginsAndSpacings
    }

    private func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pickerView)

        pickerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(200.VAdapted)
        }
    }

    private func setTimerButton() {
        view.addSubview(timerButton)

        timerButton.snp.makeConstraints { make in
            make.top.equalTo(pickerView.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(12)
        }
    }
}

// MARK: - UIPickerViewDataSource

extension CookingTimerSheetVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: // Hours
            return 25
        case 1: // Minutes
            return 60
        case 2: // Seconds
            return 60
        default:
            return 0
        }
    }
}

// MARK: - UIPickerViewDelegate

extension CookingTimerSheetVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width / 3
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row) hr"
        case 1:
            return "\(row) min"
        case 2:
            return "\(row) sec"
        default:
            return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            viewModel.hours = row
        case 1:
            viewModel.minutes = row
        case 2:
            viewModel.seconds = row
        default:
            break
        }
    }
}

// MARK: - Observed ViewModel Output & UI actions

extension CookingTimerSheetVC {
    private func observeViewModelOuput() {
        viewModel.outputCookingTimerSheetPublisher
            .sink { [unowned self] event in
                self.handleViewModelOutput(event)
            }
            .store(in: &cancellables)
    }

    private func observeActionButton() {
        timerButton
            .tapPublisher
            .sink { [unowned self] in
                handleActionButtonEvent()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Handle Output & UI Actions

extension CookingTimerSheetVC {
    private func handleViewModelOutput(_ event: CookingModeViewModel.CookingTimerSheetOutput) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch event {
            case .timerStopped:
                presentTimerFinishedAlert()
            case .updatePickerValue(let picker):
                handlePickerValues(picker)
            }
        }
    }

    private func handlePickerValues(_ pickerType: CookingModeViewModel.PickerValue) {
        switch pickerType {
        case .hours(let value):
            pickerView.selectRow(value, inComponent: 0, animated: true)
        case .minutes(let value):
            pickerView.selectRow(value, inComponent: 1, animated: true)
        case .seconds(let value):
            pickerView.selectRow(value, inComponent: 2, animated: true)
        }
    }

    private func handleActionButtonEvent() {
        viewModel.startTimer()
        dismissSheet()
    }
}

// MARK: - Navigation

extension CookingTimerSheetVC {
    private func presentTimerFinishedAlert() {
        let title = "Your timer has ended!"
        let message = "⏰⏰⏰"

        coordinator?.presentAlert(.timerFinished, title: title, message: message)
    }

    private func dismissSheet() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.dismissSheet()
        }
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension CookingTimerSheetVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
