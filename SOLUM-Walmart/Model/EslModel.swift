import Foundation

let SOLUM_TOKEN_URL = "https://stage00.common.solumesl.com/common/api/v2/token"

let COMPANY_CODE: String = "LAB"
let STORE_CODE: String = "7271"
let SOLUM_ESL_URL = "https://stage00.common.solumesl.com/common/api/v2/common/labels/led?company=\(COMPANY_CODE)&store=\(STORE_CODE)&isPartial=true"

// TOKEN //
struct TOKEN_INPUT: Codable {
    var username: String
    var password: String
}

struct ResponseMessage: Decodable {
    let access_token: String
}

struct ApiResponse: Decodable {
    let responseCode: String
    let responseMessage: ResponseMessage
}

struct ESL_RUN_INPUT: Codable {
    var ledBlinkList: [ledBlink]
}

struct ledBlink: Codable {
    var labelCode: String
    var color: String
    var duration: String
    var patternId: Int
    var multiLed: Bool
}
