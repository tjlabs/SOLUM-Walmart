import Foundation

//let SHOP_PRODUCT_URL = "https://ap-northeast-2.user.warp.tjlabs.dev/2024-12-03/category?sector_id="
let SHOP_PRODUCT_URL = "https://us-east-1.user.warp.tjlabs.dev/2024-12-09/category?sector_id="

struct ShopOutput: Codable, Equatable, Hashable {
    var category_list: [ShopCategoryList]
}

struct ShopCategoryList: Codable, Equatable, Hashable {
    var building_name: String
    var level_name: String
    var categories: [ShopCategory]
}

struct ShopCategory: Codable, Equatable, Hashable {
    var id: Int
    var name: String
    var number: Int
    var color: String
    var x: Double
    var y: Double
    var range: [Double]
    var products: [ShopProduct]
}

struct ShopProduct: Codable, Equatable, Hashable {
    var id: Int
    var name: String
    var price: Double
    var profiles: [String]
    var on_cart: Bool
    var image_url: String
    var esl_id: String
    var esl_duration: String
    var esl_color: String
}

// Each Product //
struct ProductInfo: Codable, Equatable, Hashable {
    var id: String
    var led_duration: String
    
    var category_name: String
    var category_number: Int
    var category_color: String
    var category_x: Double
    var category_y: Double
    var category_range: [Double]
    
    var product_name: String
    var product_price: Double
    var product_url: String
    var product_profile: [String]
    var product_color: String
}

struct CategoryInfo: Codable, Equatable, Hashable {
    var name: String
    var number: Int
    var color: String
    var x: Double
    var y: Double
    var range: [Double]
}


struct ESL: Codable, Equatable, Hashable {
    var id: String
    var category_x: Double
    var category_y: Double
    var product_name: String
    var led_color: String
    var led_duration: String
}
