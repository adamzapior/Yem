//
//  MainAppButton.swift
//  Yem
//
//  Created by Adam Zapiór on 16/12/2023.
//

import UIKit

protocol MainAppButtonDelegate: AnyObject {
    func mainAppButtonTapped(_ cell: MainAppButton)
}

class MainAppButton: UIButton {
    
    weak var delegate: MainAppButtonDelegate?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        self.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String, backgroundColor: UIColor) {
        self.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
    }
    
    // MARK:  UI Setup

    private func setupUI() {
        self.layer.cornerRadius = 20
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    // MARK: - Methods
    
    @objc private func buttonTapped() {
        delegate?.mainAppButtonTapped(self)
    }
   
}
