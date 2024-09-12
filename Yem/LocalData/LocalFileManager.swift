//
//  LocalFileManager.swift
//  Yem
//
//  Created by Adam Zapiór on 23/02/2024.
//

import LifetimeTracker
import UIKit

protocol LocalFileManagerProtocol {
    func saveImage(with id: String, image: UIImage) -> Result<Void, Error>
    func updateImage(with id: String, newImage: UIImage) -> Result<Void, Error>
    func deleteImage(with id: String) -> Result<Void, Error>
    func imageUrl(for id: String) -> URL?
}

class LocalFileManager: FileManager, LocalFileManagerProtocol {
    override init() {
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    func saveImage(with id: String, image: UIImage) -> Result<Void, Error> {
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            return .failure(NSError(domain: "ImageConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to JPEG"]))
        }

        do {
            let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
            try data.write(to: url)
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func updateImage(with id: String, newImage: UIImage) -> Result<Void, Error> {
        guard let data = newImage.jpegData(compressionQuality: 0.5) else {
            return .failure(NSError(domain: "ImageConversionError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not process new image"]))
        }

        let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
        do {
            try data.write(to: url)
            print("DEBUG: Image updated successfully")
            return .success(())
        } catch {
            return .failure(error)
        }
    }

    func deleteImage(with id: String) -> Result<Void, Error> {
        let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
        guard fileExists(atPath: url.path) else {
            return .failure(NSError(domain: "FileNotFoundError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Image doesn't exist"]))
        }

        do {
            try removeItem(at: url)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func imageUrl(for id: String) -> URL? {
        let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

}

#if DEBUG
extension LocalFileManager: LifetimeTrackable {
    class var lifetimeConfiguration: LifetimeConfiguration {
        return LifetimeConfiguration(maxCount: 1, groupName: "LocalFileManager")
    }
}
#endif
