import Foundation

public class NetworkManager {
    static let shared = NetworkManager()
    
    let TIMEOUT_VALUE_PUT: Double = 5.0
    let TIMEOUT_VALUE_POST: Double = 5.0
    
    let session1: URLSession
    let session2: URLSession
    let session3: URLSession
    var sessionCount: Int = 0
    var networkSessions = [URLSession]()
    
    init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = TIMEOUT_VALUE_POST
        sessionConfig.timeoutIntervalForRequest = TIMEOUT_VALUE_POST
        self.session1 = URLSession(configuration: sessionConfig)
        self.session2 = URLSession(configuration: sessionConfig)
        self.session3 = URLSession(configuration: sessionConfig)
        self.networkSessions.append(self.session1)
        self.networkSessions.append(self.session2)
        self.networkSessions.append(self.session3)
    }
    
    func initailze() {
        self.sessionCount = 0
        self.networkSessions = [URLSession]()
    }
    
    func getESL(url: String, input: Int, completion: @escaping (Int, String) -> Void) {
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = [URLQueryItem(name: "sector_id", value: String(input))]
        var requestURL = URLRequest(url: (urlComponents?.url)!)
        
        requestURL.httpMethod = "GET"
        
//        print("")
//        print("====================================")
//        print("GET ESL URL :: ", url)
//        print("GET ESL 데이터 :: ", input)
//        print("====================================")
//        print("")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = TIMEOUT_VALUE_POST
        sessionConfig.timeoutIntervalForRequest = TIMEOUT_VALUE_POST
        let session = URLSession(configuration: sessionConfig)
        let dataTask = session.dataTask(with: requestURL, completionHandler: { (data, response, error) in
            
            // [error가 존재하면 종료]
            guard error == nil else {
                // [콜백 반환]
                DispatchQueue.main.async {
                    completion(500, error?.localizedDescription ?? "Fail")
                }
                return
            }
            
            // [status 코드 체크 실시]
            let successsRange = 200..<300
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successsRange.contains(statusCode)
            else {
                // [콜백 반환]
                DispatchQueue.main.async {
                    completion(500, (response as? HTTPURLResponse)?.description ?? "Fail")
                }
                return
            }
            
            // [response 데이터 획득]
            let resultCode = (response as? HTTPURLResponse)?.statusCode ?? 500 // [상태 코드]
            guard let resultLen = data else {
                completion(500, (response as? HTTPURLResponse)?.description ?? "Fail")
                return
            }
            let resultData = String(data: resultLen, encoding: .utf8) ?? "" // [데이터 확인]
            
            // [콜백 반환]
            DispatchQueue.main.async {
//                print("")
//                print("====================================")
//                print("RESPONSE ESL 데이터 :: ", resultCode)
//                print("                 :: ", resultData)
//                print("====================================")
//                print("")
                completion(resultCode, resultData)
            }
        })
        
        // [network 통신 실행]
        dataTask.resume()
    }
}
