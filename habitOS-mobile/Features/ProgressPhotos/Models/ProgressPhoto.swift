import Foundation
import UIKit

/// A user's progress photo with metadata.
/// Decoupled from storage backend — works with local files or remote URLs.
struct ProgressPhoto: Identifiable {
    let id: UUID
    let date: Date
    let localURL: URL?
    let remoteURL: URL?
    var image: UIImage?

    init(id: UUID = UUID(), date: Date, localURL: URL? = nil, remoteURL: URL? = nil, image: UIImage? = nil) {
        self.id = id
        self.date = date
        self.localURL = localURL
        self.remoteURL = remoteURL
        self.image = image
    }
}
