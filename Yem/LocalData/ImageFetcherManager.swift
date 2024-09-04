//
//  ImageFetcherManager.swift
//  Yem
//
//  Created by Adam Zapiór on 11/08/2024.
//

import Kingfisher
import LifetimeTracker
import UIKit

protocol ImageFetcherManagerProtocol {
    func fetchImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
}

final class ImageFetcherManager: ImageFetcherManagerProtocol {
    init() {
#if DEBUG
        trackLifetime()
#endif
    }

    func fetchImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let provider = LocalFileImageDataProvider(fileURL: url)
        let fetchImageView = UIImageView()

        fetchImageView.kf.setImage(with: provider) { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    completion(.success(result.image))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
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
