import Foundation
import UIKit

/// Manages saving, loading and deleting progress photos from local storage
@Observable
final class ProgressPhotosViewModel {
    var photos: [ProgressPhoto] = []
    var isLoading = false

    private let folderName = "progress_photos"

    private var folder: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(folderName)
    }

    struct ProgressPhoto: Identifiable {
        let id: UUID
        let url: URL
        let date: Date
        var image: UIImage?
    }

    // MARK: – Load

    func loadPhotos() {
        isLoading = true
        defer { isLoading = false }

        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        let files = (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []
        photos = files
            .filter { $0.hasSuffix(".jpg") }
            .compactMap { filename -> ProgressPhoto? in
                let url = folder.appendingPathComponent(filename)
                let dateStr = String(filename.dropLast(4)) // strip .jpg
                let date = ISO8601DateFormatter().date(from: dateStr) ?? Date()
                let image = UIImage(contentsOfFile: url.path)
                return ProgressPhoto(id: UUID(), url: url, date: date, image: image)
            }
            .sorted { $0.date > $1.date }
    }

    // MARK: – Save

    func savePhoto(_ image: UIImage) {
        let dateStr = ISO8601DateFormatter().string(from: Date())
        let url = folder.appendingPathComponent("\(dateStr).jpg")
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        if let data = image.jpegData(compressionQuality: 0.85) {
            try? data.write(to: url)
        }
        loadPhotos()
    }

    // MARK: – Delete

    func delete(_ photo: ProgressPhoto) {
        try? FileManager.default.removeItem(at: photo.url)
        photos.removeAll { $0.id == photo.id }
    }
}
