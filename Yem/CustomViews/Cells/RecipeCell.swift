//
//  RecipeCell.swift
//  Yem
//
//  Created by Adam Zapiór on 31/01/2024.
//

import UIKit

class RecipeCell: UICollectionViewCell {
    static let id = "RecipeCell"
    
    var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ui.primaryContainer
        view.layer.cornerRadius = 20
        return view
    }()
    
    var cookingInfoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ui.secondaryContainer
        view.layer.cornerRadius = 20
        return view
    }()
    
    
    var recipeImage: UIImage?
    
    var titleLabel = ReusableTextLabel(fontStyle: .title3, fontWeight: .regular, textColor: .ui.primaryText)
    var perpTimeLabel = ReusableTextLabel(fontStyle: .body, fontWeight: .regular, textColor: .ui.secondaryText)
    var spicyIcon = IconImage(systemImage: "leaf", color: .ui.theme, textStyle: .body)

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: RecipeModel) {
        titleLabel.text = model.name
        perpTimeLabel.text = model.perpTimeHours
    }
    
    private func setupUI() {
        /// ContainerView
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(12)
            make.leading.equalTo(containerView.snp.leading).offset(12)
            make.trailing.equalTo(containerView.snp.trailing).offset(-6)
        }
        
        /// Cooking info details:
        addSubview(cookingInfoContainerView)
        cookingInfoContainerView.addSubview(perpTimeLabel)
        cookingInfoContainerView.addSubview(spicyIcon)
        
        cookingInfoContainerView.snp.makeConstraints { make in
            make.leading.equalTo(containerView.snp.leading).offset(6)
            make.trailing.equalTo(containerView.snp.trailing).offset(-6)
            make.bottom.equalTo(containerView.snp.bottom).offset(-4)
        }
        
        spicyIcon.snp.makeConstraints { make in
            make.top.equalTo(cookingInfoContainerView.snp.top).offset(4)
            make.leading.equalTo(cookingInfoContainerView.snp.leading).offset(9)
            make.height.width.equalTo(24)
            make.bottom.equalTo(cookingInfoContainerView.snp.bottom).offset(-6)
        }
        
        perpTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(cookingInfoContainerView.snp.top).offset(6)
            make.leading.equalTo(spicyIcon.snp.trailing).offset(6)
            make.bottom.equalTo(cookingInfoContainerView.snp.bottom).offset(-6)
        }

        
    }
}

