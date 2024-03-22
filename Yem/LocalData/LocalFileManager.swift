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

    func loadImageAsync(with id: String) async -> UIImage? {
        let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")

        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileModificationDate = fileAttributes[.modificationDate] as? Date

            if let cachedImage = ImageCache.shared.cache.object(forKey: id as NSString),
               let modificationDate = fileModificationDate,
               modificationDate <= cachedImage.modificationDate
            {
                return cachedImage.image
            } else {
                let imageData = try Data(contentsOf: url)
                if let image = UIImage(data: imageData) {
                    ImageCache.shared.setImage(image, for: id)
                    return image
                }
            }
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    func updateImage(with id: String, newImage: UIImage) -> Bool {
        if let data = newImage.jpegData(compressionQuality: 0.5) {
            let url = URL.documentsDirectory.appendingPathComponent("\(id).jpg")
            if fileExists(atPath: url.path) {
                do {
                    try data.write(to: url)
                    print("DEBUG: Image updated successfully")
                } catch {
                    print(error.localizedDescription)
                }
            }
            return true
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

class CachedImage {
    let image: UIImage
    let modificationDate: Date

    init(image: UIImage, modificationDate: Date) {
        self.image = image
        self.modificationDate = modificationDate
    }
}

class ImageCache {
    static let shared = ImageCache()
    private init() {}

    var cache = NSCache<NSString, CachedImage>()

    func setImage(_ image: UIImage, for key: String) {
        let cachedImage = CachedImage(image: image, modificationDate: Date())
        cache.setObject(cachedImage, forKey: key as NSString)
    }

    func getImage(for key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)?.image
    }
}
