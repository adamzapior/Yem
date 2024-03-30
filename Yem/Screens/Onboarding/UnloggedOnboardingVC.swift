//
//  UnloggedOnboardingVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import SnapKit
import UIKit
import LifetimeTracker


final class UnloggedOnboardingVC: UIViewController {
    var viewModel: OnboardingVM
    var coordinator: OnboardingCoordinator
    
    init(viewModel: OnboardingVM, coordinator: OnboardingCoordinator) {
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
    
    deinit {
        print("DEBUG: UnloggedOnboardingVC deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        label.text = "unlogged onb"
           
        let button = UIButton(type: .system)
        button.setTitle("Finish Onboarding", for: .normal)
        button.addTarget(self, action: #selector(finishOnboarding), for: .touchUpInside)
           
        view.addSubview(label)
        view.addSubview(button)
           
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50) // Adjusted for button
        }
           
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(20) // Adjusted for spacing
        }
           
        print("testtwstsegs")
    }
       
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        coordinator.coordinatorDidFinish()
//    }
    
    @objc func finishOnboarding() {
        coordinator.registerFinished()
        coordinator.coordinatorDidFinish()

    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

#if DEBUG
extension UnloggedOnboardingVC: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ViewControllers")
    }
}
#endif
