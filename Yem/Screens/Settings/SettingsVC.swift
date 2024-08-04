//
//  SettingsVC.swift
//  Yem
//
//  Created by Adam Zapiór on 03/04/2024.
//

import LifetimeTracker
import UIKit

class SettingsVC: UIViewController {
    // MARK: - Properties
    
    let viewModel: SettingsViewModel
    let coordinator: SettingsCoordinator
    
    // MARK: - View properties
    
    fileprivate var section: [SettingsOption] = []
    
    private let tableView = UITableView()
    
    // MARK: - Lifecycle

    init(viewModel: SettingsViewModel, coordinator: SettingsCoordinator) {
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
        section.append(contentsOf: [SettingsOption(title: "Notifications", icon: UIImage(systemName: "bell") ?? .strokedCheckmark, iconBackgroundColor: .ui.theme)])
        section.append(contentsOf: [SettingsOption(title: "About app", icon: UIImage(systemName: "info") ?? .strokedCheckmark, iconBackgroundColor: .ui.theme)])
        section.append(contentsOf: [SettingsOption(title: "Logout", icon: UIImage(systemName: "lock.open") ?? .strokedCheckmark, iconBackgroundColor: .ui.theme)])
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
    
// MARK: Delegate methods

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.reuseID, for: indexPath) as? SettingsCell else { return UITableViewCell() }
        cell.configure(with: section[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Optional: for visual feedback
        switch indexPath.row {
        case 0:
            coordinator.presentSystemSettings()
        case 1:
            coordinator.presentAboutAppAlert()
        case 2:
            coordinator.presentLogoutAlert()
        default:
            break
        }
    }
}

// MARK: - Navigation

#if DEBUG
extension SettingsVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif

struct SettingsOption {
    let title: String
    let icon: UIImage
    let iconBackgroundColor: UIColor
}
