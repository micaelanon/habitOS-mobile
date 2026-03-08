import Foundation
import UIKit

/// Manages saving, loading and deleting progress photos via a storage repository
@Observable
final class ProgressPhotosViewModel {
    var photos: [ProgressPhoto] = []
    var isLoading = false
    var errorMessage: String?

    private let repository: PhotoStorageRepositoryProtocol

    init(repository: PhotoStorageRepositoryProtocol = LocalPhotoStorageRepository()) {
        self.repository = repository
    }

    // MARK: – Load

    func loadPhotos() {
        isLoading = true
        errorMessage = nil
        Task { @MainActor in
            defer { isLoading = false }
            do {
                photos = try await repository.loadPhotos()
            } catch {
                print("[HabitOS] ProgressPhotos load error: \(error)")
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: – Save

    func savePhoto(_ image: UIImage) {
        Task { @MainActor in
            do {
                let photo = try await repository.savePhoto(image, date: Date())
                photos.insert(photo, at: 0)
            } catch {
                print("[HabitOS] ProgressPhotos save error: \(error)")
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: – Delete

    func delete(_ photo: ProgressPhoto) {
        Task { @MainActor in
            do {
                try await repository.deletePhoto(photo)
                photos.removeAll { $0.id == photo.id }
            } catch {
                print("[HabitOS] ProgressPhotos delete error: \(error)")
                errorMessage = error.localizedDescription
            }
        }
    }
}
