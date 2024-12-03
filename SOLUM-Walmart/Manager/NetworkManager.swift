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
    
    func getAllProducts(url: String, input: Int, completion: @escaping (Int, String) -> Void) {
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = [URLQueryItem(name: "sector_id", value: String(input))]
        var requestURL = URLRequest(url: (urlComponents?.url)!)
        
        requestURL.httpMethod = "GET"
        
//        print("")
//        print("====================================")
//        print("GET Shop Product URL :: ", url)
//        print("GET Shop Product 데이터 :: ", input)
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
//                print("RESPONSE Shop Product 데이터 :: ", resultCode)
//                print("                           :: ", resultData)
//                print("====================================")
//                print("")
                completion(resultCode, resultData)
            }
        })
        
        // [network 통신 실행]
        dataTask.resume()
    }
    
    func postToken(url: String, input: TOKEN_INPUT, completion: @escaping (Int, String) -> Void) {
        // [http 비동기 방식을 사용해서 http 요청 수행 실시]
        let urlComponents = URLComponents(string: url)
        var requestURL = URLRequest(url: (urlComponents?.url)!)

        requestURL.httpMethod = "POST"
        let encodingData = JSONConverter.encodeJson(param: input)
        requestURL.httpBody = encodingData
        requestURL.addValue("application/json", forHTTPHeaderField: "Content-Type")
        requestURL.setValue("\(String(describing: encodingData))", forHTTPHeaderField: "Content-Length")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = TIMEOUT_VALUE_POST
        sessionConfig.timeoutIntervalForRequest = TIMEOUT_VALUE_POST
        let session = URLSession(configuration: sessionConfig)
        
//        print("")
//        print("====================================")
//        print("POST TOKEN URL :: ", url)
//        print("POST TOKEN 데이터 :: ", input)
//        print("====================================")
//        print("")
        
        let dataTask = session.dataTask(with: requestURL, completionHandler: { (data, response, error) in
            // [error가 존재하면 종료]
            guard error == nil else {
                // [콜백 반환]
                completion(500, error?.localizedDescription ?? "Fail")
                return
            }
            
            let resultCode = (response as? HTTPURLResponse)?.statusCode ?? 500 // [상태 코드]
            // [status 코드 체크 실시]
            let successsRange = 200..<300
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successsRange.contains(statusCode)
            else {
                // [콜백 반환]
                completion(resultCode, (response as? HTTPURLResponse)?.description ?? "Fail")
                return
            }
            
            // [response 데이터 획득]
            let resultLen = data! // [데이터 길이]
            let resultData = String(data: resultLen, encoding: .utf8) ?? "" // [데이터 확인]
            
            // [콜백 반환]
            DispatchQueue.main.async {
                completion(resultCode, resultData)
            }
        })
        
        // [network 통신 실행]
        dataTask.resume()
    }
    
    func putESL(url: String, input: ESL_RUN_INPUT, completion: @escaping (Int, String) -> Void) {
        let token = TokenInfo.token
        if token == "" {
            completion(401, "Invalid Token")
            return
        }
        // Configure the URL components and request
        guard let urlComponents = URLComponents(string: url), let url = urlComponents.url else {
            completion(400, "Invalid URL")
            return
        }

        var requestURL = URLRequest(url: url)
        requestURL.httpMethod = "PUT"

        // Encode the input as JSON
        guard let encodingData = JSONConverter.encodeJson(param: input) else {
            completion(400, "Invalid input")
            return
        }
        requestURL.httpBody = encodingData

        // Set headers
        requestURL.addValue("application/json", forHTTPHeaderField: "Content-Type")
        requestURL.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        requestURL.setValue("\(encodingData.count)", forHTTPHeaderField: "Content-Length")

        // Configure the session
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = TIMEOUT_VALUE_POST
        sessionConfig.timeoutIntervalForRequest = TIMEOUT_VALUE_POST
        let session = URLSession(configuration: sessionConfig)

        // Debugging prints
//        print("")
//        print("====================================")
//        print("PUT ESL URL :: ", url)
//        print("PUT ESL 데이터 :: ", input)
//        print("====================================")
//        print("")

        // Execute the network request
        let dataTask = session.dataTask(with: requestURL, completionHandler: { (data, response, error) in
            // Handle errors
            if let error = error {
                completion(500, error.localizedDescription)
                return
            }

            // Check the response status
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(500, "Invalid response")
                return
            }

            let statusCode = httpResponse.statusCode
            let successRange = 200..<300

            if !successRange.contains(statusCode) {
                completion(statusCode, HTTPURLResponse.localizedString(forStatusCode: statusCode))
                return
            }

            // Parse the response data
            guard let responseData = data, let resultData = String(data: responseData, encoding: .utf8) else {
                completion(statusCode, "No response data")
                return
            }

            // Return the result on the main thread
            DispatchQueue.main.async {
                completion(statusCode, resultData)
            }
        })

        // Start the task
        dataTask.resume()
    }

}
