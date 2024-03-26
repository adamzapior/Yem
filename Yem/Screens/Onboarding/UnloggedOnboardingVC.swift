//
//  UnloggedOnboardingVC.swift
//  Yem
//
//  Created by Adam Zapiór on 20/03/2024.
//

import UIKit

final class UnloggedOnboardingVC: UIViewController {
    
    let viewModel: OnboardingVM
    let coordinator: OnboardingCoordinator
    
    init(viewModel: OnboardingVM, coordinator: OnboardingCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
