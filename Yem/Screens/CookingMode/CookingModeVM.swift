//
//  CookingModeVM.swift
//  Yem
//
//  Created by Adam Zapiór on 17/08/2024.
//

import AudioToolbox
import Combine
import Foundation
import LifetimeTracker

final class CookingModeViewModel {
    private let recipe: RecipeModel
    private let repository: DataRepositoryProtocol

    var uncheckedList: [ShopingListModel] = []
    var checkedList: [ShopingListModel] = []

    var timer: Timer?
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    @Published var seconds: Int = 0
    private(set) var selectedTime: TimeInterval = 0

    private var vibrationTimer: Timer?

    var timerPublisher: AnyCancellable?

    @Published var timeRemaining: String = ""

    // MARK: Input events

    let inputCookingModeEvent = PassthroughSubject<CookingModeInput, Never>()
    let inputCookingIngredientsListSheetEvent = PassthroughSubject<CookingIngredientsListSheetInput, Never>()
    let inputCookingTimerSheetEvent = PassthroughSubject<CookingTimerSheetInput, Never>()

    // MARK: Input publishers

    private var inputCookingModePublisher: AnyPublisher<CookingModeInput, Never> {
        inputCookingModeEvent.eraseToAnyPublisher()
    }

    private var inputCookingIngredientsListSheetPublisher: AnyPublisher<CookingIngredientsListSheetInput, Never> {
        inputCookingIngredientsListSheetEvent.eraseToAnyPublisher()
    }

    private var inputCookingTimerSheetPublisher: AnyPublisher<CookingTimerSheetInput, Never> {
        inputCookingTimerSheetEvent.eraseToAnyPublisher()
    }

    // MARK: Output events

    private let outputCookingModeEvent = PassthroughSubject<CookingModeOutput, Never>()
    private let outputCookingIngredientsListSheetEvent = PassthroughSubject<CookingIngredientsListSheetOutput, Never>()
    private let outputCookingTimerSheetEvent = PassthroughSubject<CookingTimerSheetOutput, Never>()

    // MARK: Output publishers

    var outputCookingModePublisher: AnyPublisher<CookingModeOutput, Never> {
        outputCookingModeEvent.eraseToAnyPublisher()
    }

    var outputCookingIngredientsListSheetPublisher: AnyPublisher<CookingIngredientsListSheetOutput, Never> {
        outputCookingIngredientsListSheetEvent.eraseToAnyPublisher()
    }

    var outputCookingTimerSheetPublisher: AnyPublisher<CookingTimerSheetOutput, Never> {
        outputCookingTimerSheetEvent.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    init(
        recipe: RecipeModel,
        repository: DataRepositoryProtocol
    ) {
        self.recipe = recipe
        self.repository = repository
        self.uncheckedList = mapIngredientsToShoppingList(ingredients: recipe.ingredientList)

        observeCookingTimerSheetInput()
        observeTimerProperties()

#if DEBUG
        trackLifetime()
#endif
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Public methods

    func mapIngredientsToShoppingList(ingredients: [IngredientModel]) -> [ShopingListModel] {
        return ingredients.map { ingredient in
            ShopingListModel(
                id: ingredient.id,
                isChecked: false,
                name: ingredient.name,
                value: ingredient.value,
                valueType: ingredient.valueType.name
            )
        }
    }

    func updateIngredientCheckStatus(ingredient: inout ShopingListModel) {
        if let index = uncheckedList.firstIndex(where: { $0.id == ingredient.id }) {
            uncheckedList.remove(at: index)
            ingredient.isChecked = true
            checkedList.append(ingredient)
        } else if let index = checkedList.firstIndex(where: { $0.id == ingredient.id }) {
            checkedList.remove(at: index)
            ingredient.isChecked = false
            uncheckedList.append(ingredient)
        }

        outputCookingIngredientsListSheetEvent.send(.reloadIngredientTable)
    }

    func clearPickerVariables() {
        hours = 0
        minutes = 0
        seconds = 0
    }

    func startTimer(with time: TimeInterval? = nil) {
        print("DEBUG: Starting timer.")
        if let time = time {
            selectedTime = time
        } else {
            selectedTime = TimeInterval(hours * 3600 + minutes * 60 + seconds)
        }
        print("DEBUG: Initial Selected Time: \(selectedTime)")

        if selectedTime > 0 {
            // Invalidate any existing timer
            timerPublisher?.cancel()
            cancellables.removeAll()

            // Create a Combine publisher and manage its lifecycle
            timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.updateTimer()
                }
            outputCookingModeEvent.send(.timerStarted)
            print("DEBUG: Timer started.")
        } else {
            print("DEBUG: Selected time is 0 or less, not starting timer.")
        }
    }

    func stopVibration() {
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }

    // MARK: - Private methods

    private func updateTimer() {
        if selectedTime > 0 {
            selectedTime -= 1
            let hours = Int(selectedTime) / 3600
            let minutes = (Int(selectedTime) % 3600) / 60
            let seconds = Int(selectedTime) % 60
            print("DEBUG: Time left: \(hours) hr \(minutes) min \(seconds) sec")

            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            outputCookingModeEvent.send(.sendTimeRemaningString(timeRemaining))
        } else {
            timeRemaining = ""
            outputCookingModeEvent.send(.sendTimeRemaningString(timeRemaining))
            
            // Cancel the timer publisher to stop updates
            timerPublisher?.cancel()
            timerPublisher = nil // Clear the reference

            cancellables.removeAll()
            timer?.invalidate()
            timer = nil
            print("DEBUG: Timer finished")

            notifyDelegatesTimerStopped()
            startVibration()
        }
    }

    private func notifyDelegatesTimerStopped() {
        outputCookingModeEvent.send(.timerStopped)
        outputCookingIngredientsListSheetEvent.send(.timerStopped)
        outputCookingTimerSheetEvent.send(.timerStopped)
    }

    private func startVibration() {
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        })
    }

    private func triggerVibration() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

// MARK: - Observed input

extension CookingModeViewModel {
    private func observeCookingTimerSheetInput() {
        inputCookingTimerSheetPublisher
            .sink { [unowned self] event in
                switch event {
                case .viewDidLoad:
                    break
                case .startTimer:
                    startTimer()
                case .sendPickerValue(let picker):
                    switch picker {
                    case .hours(let value):
                        hours = value
                    case .minutes(let value):
                        minutes = value
                    case .seconds(let value):
                        seconds = value
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Observed properties

extension CookingModeViewModel {
    private func observeTimerProperties() {
        $hours
            .sink { [unowned self] value in
                self.outputCookingTimerSheetEvent.send(.updatePickerValue(.hours(value)))
            }
            .store(in: &cancellables)

        $minutes
            .sink { [unowned self] value in
                self.outputCookingTimerSheetEvent.send(.updatePickerValue(.minutes(value)))
            }
            .store(in: &cancellables)

        $seconds
            .sink { [unowned self] value in
                self.outputCookingTimerSheetEvent.send(.updatePickerValue(.seconds(value)))
            }
            .store(in: &cancellables)
    }
}

// MARK: - Input & Output - CookingModeVC

extension CookingModeViewModel {
    enum CookingModeInput {
        case viewDidLoad
    }

    enum CookingModeOutput {
        case timerStarted
        case sendTimeRemaningString(String)
        case timerStopped
    }
}

// MARK: - Input & Output - CookingIngredientsListSheetVC

extension CookingModeViewModel {
    enum CookingIngredientsListSheetInput {
        case viewDidLoad
    }

    enum CookingIngredientsListSheetOutput {
        case timerStopped
        case reloadIngredientTable
    }
}

// MARK: - Input & Output - CookingTimerSheetVC

extension CookingModeViewModel {
    enum CookingTimerSheetInput {
        case viewDidLoad
        case startTimer
        case sendPickerValue(PickerValue)
    }

    enum CookingTimerSheetOutput {
        case timerStopped
        case updatePickerValue(PickerValue)
    }

    enum PickerValue {
        case hours(Int)
        case minutes(Int)
        case seconds(Int)
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension CookingModeViewModel: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
