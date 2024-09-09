//
//  SettingsVC.swift
//  Yem
//
//  Created by Adam Zapiór on 03/04/2024.
//

import LifetimeTracker
import UIKit

class SettingsVC: UIViewController {
    private weak var coordinator: SettingsCoordinator?
    private let viewModel: SettingsVM
        
    private var section: [SettingsOption] = []
    private let tableView = UITableView()
    
    // MARK: - Lifecycle

    init(viewModel: SettingsVM, coordinator: SettingsCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        
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
        title = "App settings"
        
        configureSection()
        setupTableView()
        setupUI()
    }

    // MARK: - UI Setup
    
    func configureSection() {
        section.append(
            contentsOf: [SettingsOption(
                title: "Notifications",
                icon: UIImage(systemName: "bell") ?? .strokedCheckmark,
                iconBackgroundColor: .ui.theme
            )]
        )
        section.append(
            contentsOf: [SettingsOption(
                title: "About app",
                icon: UIImage(systemName: "info") ?? .strokedCheckmark,
                iconBackgroundColor: .ui.theme
            )]
        )
        section.append(
            contentsOf: [SettingsOption(
                title: "Logout",
                icon: UIImage(systemName: "lock.open") ?? .strokedCheckmark,
                iconBackgroundColor: .ui.theme
            )]
        )
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.reuseID)
    }
    
    func setupUI() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
    
// MARK: UITableViewDataSource

extension SettingsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseID, for: indexPath) as? SettingsCell else { return UITableViewCell() }
        cell.configure(with: section[indexPath.row])
        
        cell.isAccessibilityElement = true
        
        switch indexPath.row {
        case 0:
            cell.accessibilityLabel = "Notification label"
            cell.accessibilityHint = "Go to app notifications in your iPhone settings"
        case 1:
            cell.accessibilityLabel = "About app label"
            cell.accessibilityHint = "Open about app info"
        case 2:
            cell.accessibilityLabel = "Logout label"
            cell.accessibilityHint = "Click to logout from app"
        default:
            break
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate

extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Optional: for visual feedback
        switch indexPath.row {
        case 0:
            navigateToSystemSettings()
        case 1:
            presentAboutAppAlert()
        case 2:
            presentLogoutAlert()
        default:
            break
        }
    }
}

// MARK: - Navigation

extension SettingsVC {
    private func navigateToSystemSettings() {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.navigateTo(.systemSettings)
        }
    }
    
    private func presentAboutAppAlert() {
        let title = "About this app"
        let message = """
        Yem is an app created for portfolio and educational purposes by Adam Zapiór. \
        You can check out more of my projects and GitHub under the username @adamzapior
        """
        
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.present(.aboutApp, title: title,
                                       message: message)
        }
    }
    
    private func presentLogoutAlert() {
        let title = "Are you sure?"
        let message = "Do you want to logout from app?"
        
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.present(.logout, title: title, message: message)
        }
    }
}

// MARK: - LifetimeTracker

#if DEBUG
extension SettingsVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
