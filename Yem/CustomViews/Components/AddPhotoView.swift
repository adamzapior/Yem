//
//  AddPhotoView.swift
//  Yem
//
//  Created by Adam Zapiór on 07/12/2023.
//

import UIKit

protocol AddPhotoViewDelegate: AnyObject {
    func addPhotoViewTapped()
}

final class AddPhotoView: UIView {
    weak var delegate: AddPhotoViewDelegate?

    private let icon = IconImage(systemImage: "camera", color: .ui.theme, textStyle: .largeTitle)
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addPhotoViewTapped))
        addGestureRecognizer(tapGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updatePhoto(with image: UIImage) {
        icon.isHidden = true
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
    }

    private func setupUI() {
        backgroundColor = .ui.primaryContainer
        layer.cornerRadius = 20

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(icon) //
        icon.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }

    // MARK: Delegate method

    @objc private func addPhotoViewTapped() {
        onTapAnimation()
        delegate?.addPhotoViewTapped()
    }
}
