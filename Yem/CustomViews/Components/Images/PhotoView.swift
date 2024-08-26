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

final class PhotoView: UIView {
    weak var delegate: AddPhotoViewDelegate?

    private var icon: IconImage
    private let imageView = UIImageView()
    private var iconString: String
    private var enableAnimations: Bool

    // MARK: Lifecycle

    override init(frame: CGRect) {
        self.iconString = "camera" // Default icon string
        self.icon = IconImage(systemImage: iconString, color: .ui.theme, textStyle: .largeTitle)
        self.enableAnimations = true
        super.init(frame: frame)

        commonInit()
    }

    convenience init(frame: CGRect, iconString: String, enableAnimations: Bool) {
        self.init(frame: frame)
        self.iconString = iconString
        self.icon = IconImage(systemImage: iconString, color: .ui.theme, textStyle: .largeTitle)
        commonInit()
        self.enableAnimations = enableAnimations
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Setup

    private func commonInit() {
        setupUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addPhotoViewTapped))
        addGestureRecognizer(tapGesture)
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
        if enableAnimations {
            defaultOnTapAnimation()
        }
        delegate?.addPhotoViewTapped()
    }
}
