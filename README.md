<img src="/Screenshots/readme-label.png?raw=true">

# Yem

Yem is a mobile app designed to help users manage their recipes, plan shopping, and enhance the cooking experience.

#### Key Features:

-   **Recipe Management**: Easily add, organize, and manage your personal recipes.
-   **Cooking Mode**: Use a dedicated cooking mode with a built-in timer to help you follow your recipes step-by-step while cooking.
-   **Shopping List**: Quickly add ingredients from your recipes to a shopping list or manually add items directly in the shopping list screen for easy grocery planning.

## Tech stack

- [x] Swift
- [x] UIKit with SnapKit
- [x] Core Data
- [x] Combine
- [x] Kingfisher
- [x] FirebaseAuth
- [x] Unit tests with XCTests
- [x] LifetimeTracker

This app is designed in **MVVM + Coordinator** with **repository pattern** and **dependency injection**.

## Navigation 

App navigation is based on coordinator pattern, which are responsible for creating and presenting view controllers and handling the flow of the application. The Destination class acts as an abstraction layer between view controllers and navigation logic. 
        
-   The Destination class defines how each screen should be rendered and interacts with its navigator.
-   Each Destination has a navigator reference, which is a weak reference to the Navigator class managing the navigation flow.    
-   Each Destination renders its respective view controller using the render() method, which returns a UIViewController.
-   The view controller's destination property is dynamically associated with the Destination instance using Objective-C runtime functions, enabling the navigation system to access and control each screen.
-   The Navigator class manages the navigation stack using a UINavigationController. It provides various methods for navigation, including presenting screens, dismissing screens, changing root view controllers, and managing sheets and alerts.

## More about design pattern

The application uses the MVVM architecture along with the previously mentioned coordinator pattern. However, in two areas of the app, more than one controller utilizes the same ViewModel. A single ViewModel is initialized for all screens in both the ManageRecipeCoordinator and the CookingModeCoordinator. Using a shared ViewModel allows for easier management of the state when adding the current recipe and during cooking mode.

The app employs Combine for communication between objects at the ViewController-ViewModel level and between ViewController-Custom UI Views. Defenitions of Input/Outpu are created in each ViewModel. These are sent using PassthroughSubject and received in a variable of type AnyPublisher. The ViewControllers observe changes in the outputPublisher, while the ViewModel listens to the inputPublisher.

For the recipe creation and cooking mode screens, each one has its own dedicated publisher. While this can introduce some complexity when sending event information, it ensures that updates are always applied to the correct screen.

## Configuration

If you want test this app on your simulator or real device by cloning repository you need to set up FireBase Auth. It's impossible to go futher than Onboarding Screen without login with Firebase.

To register app, you need to register app in Firebase console, enable email & password authorization, generate GoogleService-Info.plist file and add it to application package. 

## Screenshots
