//
//  ImageFetcherManager.swift
//  Yem
//
//  Created by Adam Zapiór on 11/08/2024.
//

import UIKit
import Kingfisher
import LifetimeTracker

protocol ImageFetcherManagerProtocol {
    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void)
}

final class ImageFetcherManager: ImageFetcherManagerProtocol {
    
    init() {
#if DEBUG
        trackLifetime()
#endif
    }
    
    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let provider = LocalFileImageDataProvider(fileURL: url)
        let fetchImageView = UIImageView()

        fetchImageView.kf.setImage(with: provider) { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    completion(result.image)
                }
            case .failure:
                completion(nil)
            }
        }
    }
}

#if DEBUG
extension ImageFetcherManager: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "ImageFetcherManager")
    }
}
#endif
