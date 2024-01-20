//
//  IngredientsTableHeaderView.swift
//  Yem
//
//  Created by Adam Zapiór on 11/12/2023.
//

import UIKit

class IngredientsTableHeaderView: UIView {
    
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
    
    

    override init (frame: CGRect) {
        super.init(frame: frame)
        configure(page: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func configure(page: Int) {
       
        for _ in 0..<pageCount {
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
