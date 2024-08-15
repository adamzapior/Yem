//
//  LocalFileManager.swift
//  Yem
//
//  Created by Adam Zapiór on 23/02/2024.
//

import LifetimeTracker
import UIKit

protocol LocalFileManagerProtocol {
    func saveImage(with id: String, image: UIImage) -> Bool
    func updateImage(with id: String, newImage: UIImage) -> Bool
    func deleteImage(with id: String)
    func imageUrl(for id: String) -> URL?
}

class LocalFileManager: FileManager, LocalFileManagerProtocol {
    override init() {
        super.init()
#if DEBUG
        trackLifetime()
#endif
    }

    func saveImage(with id: String, image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            print("DEBUG: Could not convert image to JPEG")
            return false
        }

        do {
            let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
            try data.write(to: url)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }

    func updateImage(with id: String, newImage: UIImage) -> Bool {
        if let data = newImage.jpegData(compressionQuality: 0.5) {
            let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
            do {
                try data.write(to: url)
                print("DEBUG: Image updated successfully")
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        } else {
            print("DEBUG: Could not process new image")
            return false
        }
    }

    func deleteImage(with id: String) {
        let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
        if fileExists(atPath: url.path) {
            do {
                try removeItem(at: url)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("DEBUG: Image doesn't exists")
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
