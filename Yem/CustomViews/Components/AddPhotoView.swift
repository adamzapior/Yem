//
//  AddPhotoView.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import UIKit

final class AddPhotoView: UIView {
    
    private let icon = IconImage(systemImage: "camera", color: .ui.theme, textStyle: .largeTitle)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .ui.primaryContainer
        layer.cornerRadius = 20
        
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    
    
    
    
}
