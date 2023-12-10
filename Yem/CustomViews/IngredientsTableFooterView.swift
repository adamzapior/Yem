//
//  IngredientsTableHeaderView.swift
//  Yem
//
//  Created by Adam Zapiór on 10/12/2023.
//

import UIKit

class IngredientsTableFooterView: UIView {
    
    let screenWidth = UIScreen.main.bounds.width
    
    private let addIcon = IconImageView(systemImage: "plus", color: .ui.theme, textStyle: .body, contentMode: .scaleAspectFit)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func configure() {
        addSubview(addIcon)
        addIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(screenWidth)
        }
       
    }
}
