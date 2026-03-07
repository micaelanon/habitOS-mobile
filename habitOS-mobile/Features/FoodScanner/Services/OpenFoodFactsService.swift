import Foundation

/// Calls the OpenFoodFacts v2 API to look up product information by barcode
final class OpenFoodFactsService {
    static let shared = OpenFoodFactsService()
    private init() {}

    private let baseURL = "https://world.openfoodfacts.org/api/v0/product"
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        return URLSession(configuration: config)
    }()

    func lookup(barcode: String) async throws -> OpenFoodFactsProduct? {
        guard let url = URL(string: "\(baseURL)/\(barcode).json?fields=product_name,brands,image_front_url,nutriscore_grade,nutriments") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.setValue("habitOS-mobile/1.0 (iOS)", forHTTPHeaderField: "User-Agent")

        let (data, _) = try await session.data(for: request)
        let response = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)
        return response.status == 1 ? response.product : nil
    }
}
