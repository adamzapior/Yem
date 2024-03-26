//
//  LocalFileManager.swift
//  Yem
//
//  Created by Adam Zapiór on 23/02/2024.
//

import UIKit

class LocalFileManager: FileManager {
    static let instance = LocalFileManager()

    override private init() {}

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
}

extension LocalFileManager {
    func imageUrl(for id: String) -> URL? {
        let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }
}
