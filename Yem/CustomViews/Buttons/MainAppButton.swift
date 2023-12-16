//
//  MainAppButton.swift
//  Yem
//
//  Created by Adam Zapiór on 16/12/2023.
//

import UIKit

class MainAppButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
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
    

    private func setupUI() {
        self.layer.cornerRadius = 20
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }

   
}
