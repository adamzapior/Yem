//
//  MainAppButton.swift
//  Yem
//
//  Created by Adam Zapiór on 16/12/2023.
//

import UIKit

protocol ActionButtonDelegate: AnyObject {
    func actionButtonTapped(_ button: ActionButton)
}

final class ActionButton: UIButton {
    weak var delegate: ActionButtonDelegate?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        
        self.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(title: String, backgroundColor: UIColor, isShadownOn: Bool = false) {
        self.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.backgroundColor = backgroundColor
        
        if isShadownOn {
            self.layer.masksToBounds = false
            self.layer.shadowRadius = 8
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
            self.layer.shadowOpacity = 0.3
            self.layer.shadowColor = UIColor.ui.theme.cgColor
        }
    }
    
    // MARK: UI Setup

    private func setupUI() {
        self.layer.cornerRadius = 20
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        self.snp.makeConstraints { make in
            make.height.equalTo(54.HAdapted)
        }
    }
    
    // MARK: - Methods
    
    @objc private func buttonTapped() {
        self.delegate?.actionButtonTapped(self)
        self.onTapAnimation()
    }
}
