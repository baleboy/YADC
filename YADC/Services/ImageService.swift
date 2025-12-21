//
//  ImageService.swift
//  YADC
//
//  Created by Claude on 21.12.2025.
//

import UIKit

final class ImageService {
    static let shared = ImageService()

    private let fileManager = FileManager.default
    private let imageDirectoryName = "RecipeImages"
    private let compressionQuality: CGFloat = 0.8
    private let maxImageDimension: CGFloat = 1200

    private init() {
        createImageDirectoryIfNeeded()
    }

    // MARK: - Directory Management

    private var imagesDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(imageDirectoryName)
    }

    private func createImageDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try? fileManager.createDirectory(at: imagesDirectory,
                                            withIntermediateDirectories: true)
        }
    }

    private func imagePath(for recipeId: UUID) -> URL {
        imagesDirectory.appendingPathComponent("\(recipeId.uuidString).jpg")
    }

    // MARK: - Public API

    func saveImage(_ image: UIImage, for recipeId: UUID) -> Bool {
        guard let resizedImage = resizeImageIfNeeded(image),
              let data = resizedImage.jpegData(compressionQuality: compressionQuality) else {
            return false
        }

        do {
            try data.write(to: imagePath(for: recipeId))
            return true
        } catch {
            print("Failed to save image: \(error)")
            return false
        }
    }

    func loadImage(for recipeId: UUID) -> UIImage? {
        let path = imagePath(for: recipeId)
        guard fileManager.fileExists(atPath: path.path) else { return nil }
        return UIImage(contentsOfFile: path.path)
    }

    func deleteImage(for recipeId: UUID) {
        let path = imagePath(for: recipeId)
        try? fileManager.removeItem(at: path)
    }

    func imageExists(for recipeId: UUID) -> Bool {
        fileManager.fileExists(atPath: imagePath(for: recipeId).path)
    }

    // MARK: - Image Processing

    private func resizeImageIfNeeded(_ image: UIImage) -> UIImage? {
        let size = image.size
        let maxDimension = max(size.width, size.height)

        guard maxDimension > maxImageDimension else { return image }

        let scale = maxImageDimension / maxDimension
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
