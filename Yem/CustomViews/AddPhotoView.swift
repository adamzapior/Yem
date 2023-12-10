//
//  AddPhotoView.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import UIKit

class AddPhotoView: UIView {

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
    }
    
}
