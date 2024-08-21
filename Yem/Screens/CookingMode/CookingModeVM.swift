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

protocol CookingIngredientsListSheetVCDelegate: AnyObject {
    func reloadTable()
    func timerStoppedWhenIngredientSheetOpen()
}

protocol CookingModeVCDelegate: AnyObject {
    func timerStarted()
    func timerStopped()
}

protocol CookingTimerSheetVCDelegate: AnyObject {
    func timerStoppedWhenTimerSheetOpen()
}

final class CookingModeViewModel {
    weak var delegate: CookingModeVCDelegate?
    weak var delegateIngredientSheet: CookingIngredientsListSheetVCDelegate?
    weak var delegateTimerSheet: CookingTimerSheetVCDelegate?

    let recipe: RecipeModel
    let repository: DataRepositoryProtocol

    var uncheckedList: [ShopingListModel] = []
    var checkedList: [ShopingListModel] = []

    var timer: Timer?
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    private(set) var selectedTime: TimeInterval = 0

    var vibrationTimer: Timer?

    @Published
    var timeRemaining: String = ""

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    init(
        recipe: RecipeModel,
        repository: DataRepositoryProtocol
    ) {
        self.recipe = recipe
        self.repository = repository
        self.uncheckedList = mapIngredientsToShoppingList(ingredients: recipe.ingredientList)

#if DEBUG
        trackLifetime()
#endif
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Public methods
    
    // Ingredient list methods

    func mapIngredientsToShoppingList(ingredients: [IngredientModel]) -> [ShopingListModel] {
        return ingredients.map { ingredient in
            ShopingListModel(
                id: ingredient.id,
                isChecked: false,
                name: ingredient.name,
                value: ingredient.value,
                valueType: ingredient.valueType
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

        DispatchQueue.main.async {
            self.delegateIngredientSheet?.reloadTable()
        }
    }

    func clearPickerVariables() {
        hours = 0
        minutes = 0
        seconds = 0
    }
    
    // Timer methods

    func startTimer(with time: TimeInterval? = nil) {
        print("Starting timer.")
        if let time = time {
            selectedTime = time
        } else {
            selectedTime = TimeInterval(hours * 3600 + minutes * 60 + seconds)
        }
        print("Initial Selected Time: \(selectedTime)")

        if selectedTime > 0 {
            /// Invalidate any existing timer to prevent multiple timers from running
            timer?.invalidate()
            timer = nil
            cancellables.removeAll()
            
            /// Create a Combine publisher and manage its lifecycle
            let timerPublisher = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
            
            timerPublisher
                .sink { [weak self] _ in
                    self?.updateTimer()
                }
                .store(in: &cancellables)

            delegate?.timerStarted()
            print("Timer started.")
        } else {
            print("Selected time is 0 or less, not starting timer.")
        }
    }

    func saveTimerState() {
        UserDefaults.standard.set(Date(), forKey: "TimerStartDate")
        UserDefaults.standard.set(selectedTime, forKey: "TimerDuration")
    }
    
    func restoreTimerState() {
        guard timer == nil else {
            print("test")
            return
        }

        if let startDate = UserDefaults.standard.value(forKey: "TimerStartDate") as? Date,
           let duration = UserDefaults.standard.value(forKey: "TimerDuration") as? TimeInterval
        {
            let currentDate = Date()
            let timePassed = currentDate.timeIntervalSince(startDate)
            let result = max(duration - timePassed, 0)

            print("Restoring timer state.")
            print("Current Date: \(currentDate)")
            print("Start Date: \(startDate)")
            print("Time Passed: \(timePassed)")
            print("Restored Selected Time: \(result)")

            if selectedTime > 0 {
                startTimer(with: result)
            } else {
                timeRemaining = "00:00:00"
                print("Timer already finished while in background.")
            }
        } else {
            timeRemaining = "00:00:00"
            print("No saved timer state found.")
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
            print("Time left: \(hours) hr \(minutes) min \(seconds) sec")

            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)

        } else {
            timeRemaining = ""

            timer?.invalidate()
            timer = nil
            print("Timer finished")

            cancellables.removeAll()
            notifyDelegatesTimerStopped()
            startVibration()
        }
    }

    private func notifyDelegatesTimerStopped() {
        DispatchQueue.main.async {
            self.delegate?.timerStopped()
            self.delegateIngredientSheet?.timerStoppedWhenIngredientSheetOpen()
            self.delegateTimerSheet?.timerStoppedWhenTimerSheetOpen()
        }
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

#if DEBUG
extension CookingModeViewModel: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewModels")
    }
}
#endif
