import Foundation
import UIKit

/// Local-only photo storage using the app's Documents directory.
/// Drop-in replacement: swap with a Supabase-backed repository when the
/// `body-photos` bucket is available, without changing the ViewModel or View.
final class LocalPhotoStorageRepository: PhotoStorageRepositoryProtocol {
    private let folderName = "progress_photos"
    private let maxDimension: CGFloat = 1200
    private let jpegQuality: CGFloat = 0.85

    private var folder: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(folderName)
    }

    // MARK: – Save

    func savePhoto(_ image: UIImage, date: Date) async throws -> ProgressPhoto {
        let resized = downsized(image)
        guard let data = resized.jpegData(compressionQuality: jpegQuality) else {
            throw PhotoStorageError.encodingFailed
        }
        let dateStr = ISO8601DateFormatter().string(from: date)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent("\(dateStr).jpg")
        try data.write(to: url)
        return ProgressPhoto(date: date, localURL: url, image: resized)
    }

    // MARK: – Load

    func loadPhotos() async throws -> [ProgressPhoto] {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let files = (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []
        return files
            .filter { $0.hasSuffix(".jpg") }
            .compactMap { filename -> ProgressPhoto? in
                let url = folder.appendingPathComponent(filename)
                let dateStr = String(filename.dropLast(4))
                let date = ISO8601DateFormatter().date(from: dateStr) ?? Date()
                let image = UIImage(contentsOfFile: url.path)
                return ProgressPhoto(date: date, localURL: url, image: image)
            }
            .sorted { $0.date > $1.date }
    }

    // MARK: – Delete

    func deletePhoto(_ photo: ProgressPhoto) async throws {
        guard let url = photo.localURL else { return }
        try FileManager.default.removeItem(at: url)
    }

    // MARK: – Image Processing

    /// Downscale image so longest edge ≤ maxDimension (spec: 1200px).
    private func downsized(_ image: UIImage) -> UIImage {
        let size = image.size
        guard max(size.width, size.height) > maxDimension else { return image }
        let scale = maxDimension / max(size.width, size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

enum PhotoStorageError: Error, LocalizedError {
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed: return "No se pudo codificar la imagen."
        }
    }
}
