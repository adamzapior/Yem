
//
//  InstructionTableHeaderView.swift
//  Yem
//
//  Created by Adam Zapiór on 20/01/2024.
//

import UIKit

final class InstructionTableHeaderView: UIView {
    private let screenWidth = UIScreen.main.bounds.width
    
    private let pageStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 4
        return sv
    }()
    
    private let pageCount = 3
    private var pageViews = [UIView]()
    
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure(page: 2)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Setup

    func configure(page: Int) {
        for _ in 0 ..< pageCount {
            let divider = UIView.createDivider(color: .gray)
            pageStackView.addArrangedSubview(divider)
            pageViews.append(divider)
        }
        
        pageViews[page].backgroundColor = .ui.theme
        
        addSubview(pageStackView)
        pageStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.width.equalToSuperview().offset(12)
        }
    }
}
