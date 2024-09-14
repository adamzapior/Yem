//
//  MockLocalFileManager.swift
//  YemTests
//
//  Created by Adam Zapiór on 11/08/2024.
//

import UIKit
@testable import Yem

//final class MockLocalFileManager: LocalFileManagerProtocol {
//    var testImageUrl: URL?
//    var testImage: UIImage?
//
//    func saveImage(with id: String, image: UIImage) -> Bool { return true }
//    func updateImage(with id: String, newImage: UIImage) -> Bool { return true }
//    func deleteImage(with id: String) {}
//    func imageUrl(for id: String) -> URL? { return testImageUrl }
//}


final class MockLocalFileManager: LocalFileManagerProtocol {
    var testImageUrl: URL?
    var testImage: UIImage?
    
    func saveImage(with id: String, image: UIImage) -> Result<Void, Error> {
        return .success(())
    }
    
    func updateImage(with id: String, newImage: UIImage) -> Result<Void, Error> {
        return .success(())
    }
    
    func deleteImage(with id: String) -> Result<Void, Error> {
        return .success(())
    }
    
    func imageUrl(for id: String) -> URL? {
        return testImageUrl
    }
}
