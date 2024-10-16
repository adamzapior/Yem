//
//  RecipeCell.swift
//  Yem
//
//  Created by Adam Zapiór on 31/01/2024.
//

import Kingfisher
import UIKit

final class RecipeCell: UICollectionViewCell {
    static let id = "RecipeCell"
    
    var localFileManager: LocalFileManagerProtocol?
    var imageFetcherManager: ImageFetcherManagerProtocol?
    
    var recipeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.alpha = 0.7
        imageView.isHidden = true
        return imageView
    }()
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ui.primaryContainer
        view.layer.cornerRadius = 20
        return view
    }()
    
    private var cookingInfoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ui.secondaryContainer.withAlphaComponent(0.85)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private var titleLabel = TextLabel(
        fontStyle: .title3,
        fontWeight: .semibold,
        textColor: .ui.primaryText
    )
    
    private var prepTimeLabel = TextLabel(
        fontStyle: .footnote,
        fontWeight: .regular,
        textColor: .ui.secondaryText
    )
    private var spicyIcon = IconImage(
        systemImage: "leaf",
        color: .ui.theme,
        textStyle: .body
    )
    
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLineBreakModeStrategyForLables()
    }
  
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        recipeImage.image = nil
        recipeImage.isHidden = true
        recipeImage.kf.cancelDownloadTask()
    }
    
    // MARK: UI Setup
    
    func configure(
        with model: RecipeModel,
        image: UIImage?,
        localFileManager: LocalFileManagerProtocol?,
        imageFetcherManager: ImageFetcherManagerProtocol?
    ) {
        self.localFileManager = localFileManager
        self.imageFetcherManager = imageFetcherManager
        
        titleLabel.text = model.name

        prepTimeLabel.text = model.getPrepTimeString()
        
        switch model.spicy {
        case .mild:
            spicyIcon.tintColor = .ui.spicyMild
        case .medium:
            spicyIcon.tintColor = .ui.spicyMedium
        case .hot:
            spicyIcon.tintColor = .ui.spicyHot
        case .veryHot:
            spicyIcon.tintColor = .ui.spicyVeryHot
        default: break
        }
        
        if model.isImageSaved, let fileManager = localFileManager, let imageFetcher = imageFetcherManager {
            if let imageUrl = fileManager.imageUrl(for: model.id.uuidString) {
                imageFetcher.fetchImage(from: imageUrl) { [weak self] image in
                    guard let self = self else { return }
                    self.recipeImage.image = image
                    self.recipeImage.isHidden = (image == nil)
                }
            }
        }
    }
    
    private func setupUI() {
        /// ContainerView
        addSubview(containerView)
        containerView.addSubview(recipeImage)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }
        
        recipeImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(12)
            make.leading.equalTo(containerView.snp.leading).offset(12)
            make.trailing.equalTo(containerView.snp.trailing).offset(-6)
        }
                
        /// Cooking info details:
        containerView.addSubview(cookingInfoContainerView)
        cookingInfoContainerView.addSubview(prepTimeLabel)
        cookingInfoContainerView.addSubview(spicyIcon)
        
        cookingInfoContainerView.snp.makeConstraints { make in
            make.leading.equalTo(containerView.snp.leading).offset(6)
            make.trailing.equalTo(containerView.snp.trailing).offset(-6)
            make.bottom.equalTo(containerView.snp.bottom).offset(-4)
            make.height.greaterThanOrEqualTo(40)
            make.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(8)
            
            spicyIcon.snp.makeConstraints { make in
                make.top.equalTo(cookingInfoContainerView.snp.top).offset(6)
                make.leading.equalTo(cookingInfoContainerView.snp.leading).offset(9)
                make.height.width.equalTo(24)
                make.bottom.lessThanOrEqualTo(cookingInfoContainerView.snp.bottom).offset(-6)
            }
            
            prepTimeLabel.snp.makeConstraints { make in
                make.top.equalTo(cookingInfoContainerView.snp.top).offset(6)
                make.leading.equalTo(spicyIcon.snp.trailing).offset(6)
                make.bottom.equalTo(cookingInfoContainerView.snp.bottom).offset(-6)
                make.trailing.equalTo(cookingInfoContainerView.snp.trailing).offset(-2)
            }
            
            cookingInfoContainerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            cookingInfoContainerView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            
            prepTimeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            prepTimeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }
    
    private func setupLineBreakModeStrategyForLables() {
        titleLabel.lineBreakMode = .byTruncatingTail
        prepTimeLabel.lineBreakMode = .byTruncatingTail
    }
}
