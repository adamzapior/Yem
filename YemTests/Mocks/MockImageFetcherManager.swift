//
//  MockImageFetcherManager.swift
//  YemTests
//
//  Created by Adam Zapiór on 11/08/2024.
//

import UIKit
@testable import Yem

final class MockImageFetcherManager: ImageFetcherManagerProtocol {
    func fetchImage(from url: URL, completion: @escaping (Result<UIImage, any Error>) -> Void) {
        completion(.success(stubbedImage!))
    }
    
    var stubbedImage: UIImage?

    init(stubbedImage: UIImage?) {
        self.stubbedImage = stubbedImage
    }

    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        completion(stubbedImage)
    }
}


