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
        let options: KingfisherOptionsInfo = [
            .cacheOriginalImage,
            .forceRefresh   /// force is necessary to handle updated recipe photos
                            /// this can be avoided by getting the exact id of the updated image - todo in future
        ]
        let fetchImageView = UIImageView()
        

        fetchImageView.kf.setImage(with: provider, options: options) { result in
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
