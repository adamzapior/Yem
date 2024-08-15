//
//  TabBarCoordinator.swift
//  Yem
//
//

import FirebaseAuth
import LifetimeTracker
import UIKit

protocol DestinationProviding {
    func render() -> UIViewController
}

final class TabBarCoordinatorAdapter: Destination {
    private weak var coordinator: TabBarCoordinator?

    init(coordinator: TabBarCoordinator) {
        self.coordinator = coordinator
        super.init()
#if DEBUG
        trackLifetime()
#endif

        print("DEBUG: TabBarCoordinatorAdapter init")
    }

    deinit {
        print("DEBUG: TabBarCoordinatorAdapter deinit")
    }

    override func render() -> UIViewController {
        return coordinator!.render()
    }
}

final class TabBarCoordinator: UITabBarController, DestinationProviding {
    func render() -> UIViewController {
        return self
    }

    weak var parentCoordinator: AppCoordinator?

    var recipesNavigator: Navigator?
    var shoppingNavigator: Navigator?

    let dataRepository: DataRepository
    let authManager: AuthenticationManager
    let localFileManager: LocalFileManagerProtocol
    let imageFetcherManager: ImageFetcherManagerProtocol

    init(
        currentUser: UserModel,
        dataRepository: DataRepository,
        authManager: AuthenticationManager,
        localFileManager: LocalFileManagerProtocol,
        imageFetcherManager: ImageFetcherManagerProtocol
    ) {
        self.dataRepository = dataRepository
        self.authManager = authManager
        self.localFileManager = localFileManager
        self.imageFetcherManager = imageFetcherManager

        super.init(nibName: nil, bundle: nil)
#if DEBUG
        trackLifetime()
#endif
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let recipesCoordinator = RecipesListCoordinator(
            repository: dataRepository,
            viewModel: RecipesListVM(
                repository: dataRepository,
                localFileManager: localFileManager, imageFetcherManager: imageFetcherManager
            ),
            authManager: authManager,
            localFileManager: localFileManager, imageFetcherManager: imageFetcherManager
        )
        recipesNavigator = Navigator(start: recipesCoordinator)
        recipesCoordinator.navigator = recipesNavigator

        let shoppingCoordinator = ShopingListCoordinator(
            parentCoordinator: self,
            repository: dataRepository,
            viewModel: ShopingListVM(
                repository: dataRepository
            )
        )
        shoppingNavigator = Navigator(start: shoppingCoordinator)
        shoppingCoordinator.navigator = shoppingNavigator

        if let recipesNav = recipesNavigator?.navigationController, let shopingNav = shoppingNavigator?.navigationController {
            recipesNav.tabBarItem = UITabBarItem(
                title: "Recipes",
                image: UIImage(systemName: "book"),
                selectedImage: nil
            )
            shopingNav.tabBarItem = UITabBarItem(
                title: "Shopping",
                image: UIImage(systemName: "cart"),
                selectedImage: nil
            )
            viewControllers = [recipesNav, shopingNav]
        }
    }

    func clearAllNavigators() {
        recipesNavigator?.clearAllViewControllers()
        shoppingNavigator?.clearAllViewControllers()

        recipesNavigator = nil
        shoppingNavigator = nil

        print(recipesNavigator.debugDescription)
        print(shoppingNavigator.debugDescription)
        print("DEBUG: Navigators cleared: recipesNavigator - \(recipesNavigator.debugDescription), shoppingNavigator - \(shoppingNavigator.debugDescription)")
    }
}

#if DEBUG
extension TabBarCoordinatorAdapter: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif

#if DEBUG
extension TabBarCoordinator: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "Coordinators")
    }
}
#endif
