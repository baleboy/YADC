//
//  JournalImageService.swift
//  YADC
//
//  Created by Francesco Balestrieri on 21.12.2025.
//

import UIKit

final class JournalImageService {
    static let shared = JournalImageService()

    private let fileManager = FileManager.default
    private let imageDirectoryName = "JournalImages"
    private let compressionQuality: CGFloat = 0.8
    private let maxImageDimension: CGFloat = 1200
    static let maxPhotosPerEntry = 5

    private init() {
        createImageDirectoryIfNeeded()
    }

    // MARK: - Directory Management

    private var imagesDirectory: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(imageDirectoryName)
    }

    private func entryDirectory(for entryId: UUID) -> URL {
        imagesDirectory.appendingPathComponent(entryId.uuidString)
    }

    private func createImageDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try? fileManager.createDirectory(at: imagesDirectory,
                                            withIntermediateDirectories: true)
        }
    }

    private func createEntryDirectoryIfNeeded(for entryId: UUID) {
        let entryDir = entryDirectory(for: entryId)
        if !fileManager.fileExists(atPath: entryDir.path) {
            try? fileManager.createDirectory(at: entryDir,
                                            withIntermediateDirectories: true)
        }
    }

    private func imagePath(for entryId: UUID, at index: Int) -> URL {
        entryDirectory(for: entryId).appendingPathComponent("\(index).jpg")
    }

    // MARK: - Public API

    func saveImage(_ image: UIImage, for entryId: UUID, at index: Int) -> Bool {
        guard index >= 0 && index < JournalImageService.maxPhotosPerEntry else { return false }

        createEntryDirectoryIfNeeded(for: entryId)

        guard let resizedImage = resizeImageIfNeeded(image),
              let data = resizedImage.jpegData(compressionQuality: compressionQuality) else {
            return false
        }

        do {
            try data.write(to: imagePath(for: entryId, at: index))
            return true
        } catch {
            print("Failed to save journal image: \(error)")
            return false
        }
    }

    func loadImage(for entryId: UUID, at index: Int) -> UIImage? {
        let path = imagePath(for: entryId, at: index)
        guard fileManager.fileExists(atPath: path.path) else { return nil }
        return UIImage(contentsOfFile: path.path)
    }

    func loadImages(for entryId: UUID, count: Int) -> [UIImage] {
        var images: [UIImage] = []
        for i in 0..<min(count, JournalImageService.maxPhotosPerEntry) {
            if let image = loadImage(for: entryId, at: i) {
                images.append(image)
            }
        }
        return images
    }

    func loadThumbnail(for entryId: UUID) -> UIImage? {
        loadImage(for: entryId, at: 0)
    }

    func deleteImage(for entryId: UUID, at index: Int, totalCount: Int) {
        let path = imagePath(for: entryId, at: index)
        try? fileManager.removeItem(at: path)

        // Reindex remaining images to fill the gap
        for i in (index + 1)..<totalCount {
            let oldPath = imagePath(for: entryId, at: i)
            let newPath = imagePath(for: entryId, at: i - 1)
            try? fileManager.moveItem(at: oldPath, to: newPath)
        }
    }

    func deleteAllImages(for entryId: UUID) {
        let entryDir = entryDirectory(for: entryId)
        try? fileManager.removeItem(at: entryDir)
    }

    func imageExists(for entryId: UUID, at index: Int) -> Bool {
        fileManager.fileExists(atPath: imagePath(for: entryId, at: index).path)
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
