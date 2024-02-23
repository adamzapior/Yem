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

    func saveImage(with id: String, image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.5) {
            do {
                let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
                try data.write(to: url)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("Could not save image")
        }
    }

    func loadImage(with id: String) -> UIImage? {
        let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
        do {
            let imageData = try Data(contentsOf: url)
            return UIImage(data: imageData)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func updateImage(with id: String, newImage: UIImage) {
        if let data = newImage.jpegData(compressionQuality: 0.5) {
            let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
            if fileExists(atPath: url.path) {
                do {
                    try data.write(to: url)
                    print("Image updated successfully")
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print("Image to update does not exist, saving as new image")
                saveImage(with: id, image: newImage)
            }
        } else {
            print("Could not process new image")
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
            print("Image doesn't exists")
        }
    }
}
