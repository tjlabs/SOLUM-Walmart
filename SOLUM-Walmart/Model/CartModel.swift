import Foundation

let ESL_PRODUCT_URL = "https://ap-northeast-2.user.warp.tjlabs.dev/2024-11-29/esl?sector_id="

// Products //
struct Esl: Codable, Equatable, Hashable {
    var id: String
    var color: String
    var x: Double
    var y: Double
    var duration: String
    var product_name: String
    var product_description: String
    var product_price: Double
    var product_url: String
}

struct EslList: Codable {
    var building_name: String
    var level_name: String
    var esls: [Esl]
}

struct OutputEsl: Codable {
    var esl_list: [EslList]
}
