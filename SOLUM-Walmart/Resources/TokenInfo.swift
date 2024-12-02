class TokenInfo {
    static let username: String = "leo.shin@tjlabscorp.com"
    static let password: String = "TJlabs0407@"
    
    static var token: String = ""
    
    static func setToken(token: String) {
        TokenInfo.token = token
    }
}
