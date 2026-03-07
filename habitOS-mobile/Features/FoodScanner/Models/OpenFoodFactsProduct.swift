import Foundation

/// Product data from the OpenFoodFacts API
struct OpenFoodFactsProduct: Decodable, Equatable {
    let productName: String?
    let brands: String?
    let imageURL: String?
    let nutriscoreGrade: String?
    let nutriments: Nutriments?

    struct Nutriments: Decodable, Equatable {
        let energyKcal: Double?
        let proteins: Double?
        let carbohydrates: Double?
        let fat: Double?
        let fiber: Double?
        let salt: Double?

        enum CodingKeys: String, CodingKey {
            case energyKcal = "energy-kcal_100g"
            case proteins = "proteins_100g"
            case carbohydrates = "carbohydrates_100g"
            case fat = "fat_100g"
            case fiber = "fiber_100g"
            case salt = "salt_100g"
        }
    }

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case imageURL = "image_front_url"
        case nutriscoreGrade = "nutriscore_grade"
        case nutriments
    }
}

struct OpenFoodFactsResponse: Decodable {
    let status: Int
    let product: OpenFoodFactsProduct?
}
