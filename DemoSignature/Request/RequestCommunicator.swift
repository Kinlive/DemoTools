//
//  RequestCommunicator.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/15.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

class RequestCommunicator<requestBaseTypeT: RequestBaseType>: NSObject, URLSessionDownloadDelegate {

    typealias RequestCompletionHandler = (Result<CommunicatorResponse, NetworkError>) -> Void
    
    var downloadCompletionBlock: ((_ data: Data) -> Void)?
    

    public func request(type: requestBaseTypeT, completionHandler: @escaping RequestCompletionHandler) {
        
        // 選擇request 方式
        switch type.task {
        case .requestPlain:
            
            // prepare url
            let url = URL(target: type)
            var request = URLRequest(url: url)
            request.httpMethod = type.method.rawValue
            request.allHTTPHeaderFields = type.headers
            if request.allHTTPHeaderFields?["Content-Type"] == nil {
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            fetchedDataByDataTask(from: request, target: type, completion: completionHandler)
            
        case .requestJSONBody(let parameters):
            requestWithJSONBody(target: type, parameters: parameters, completion: completionHandler)
        
        case .requestParameters(let parameters):
            requestWithURL(type, parameters: parameters, completion: completionHandler)
        
        case .requestURLEncodedBody(let parameters):
            requestWithUrlencodedBody(type, parameters: parameters, completion: completionHandler)
        
        case .requestmultipartFormdata(let params, let mimeType):
            requestWithFormData(type, parameters: params, mimeType: mimeType, completion: completionHandler)
            
        }
        
    }
  
    
    // ================request functions=====================
    /// normal request with callback
    private func fetchedDataByDataTask(from request: URLRequest, target: requestBaseTypeT, completion:  @escaping RequestCompletionHandler) {
        
        printLog(logs: [
            "---------------------------\(target.path)-----------------------------------",
            "ContentType: \(String(describing: request.allHTTPHeaderFields))",
            "URL: \(String(describing: request.url))",
            "Method: \(String(describing: request.httpMethod))",
            "Body: \(String(describing: request.httpBody))"
        ], title: "REQUEST")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            let result = self.convertToResult(response: response as? HTTPURLResponse, data: data, error: error)
             completion(result)
        }
        task.resume()
    }
    
    /// query parameters
    private func requestWithURL(_ target: requestBaseTypeT, parameters: [String: Any], completion: @escaping RequestCompletionHandler) {
        let url = URL(target: target)
        
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
       
        urlComponents.queryItems = []
        
        for (key, value) in parameters {
            guard let value = value as? String else { return }
            urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        
        guard let queryedURL = urlComponents.url else { return }
        
        var request = URLRequest(url: queryedURL)
        
        request.httpMethod = target.method.rawValue
        if request.allHTTPHeaderFields?["Content-Type"] == nil {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        fetchedDataByDataTask(from: request, target: target, completion: completion)
    }
    
    // json body
    private func requestWithJSONBody(target: requestBaseTypeT, parameters: [String: Any], completion: @escaping RequestCompletionHandler) {
        
        let url = URL(target: target)
        
        var request = URLRequest(url: url)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
            
        } catch let error {
            print(error)
        }
        request.httpMethod = target.method.rawValue
        
        if let headers = target.headers {
            request.allHTTPHeaderFields = headers
        }
        
        if request.allHTTPHeaderFields?["Content-Type"] == nil {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        fetchedDataByDataTask(from: request, target: target, completion: completion)
    }
    
    // contentType: form-urlencoded
    private func requestWithUrlencodedBody(_ target: requestBaseTypeT, parameters: [String: Any], completion: @escaping RequestCompletionHandler) {
        
        guard let params = parameters as? [String: String] else { return }
        
        let url = URL(target: target)
        var request = URLRequest(url: url)
        
        request.encodeParameters(parameters: params)
        
        fetchedDataByDataTask(from: request, target: target, completion: completion)
        
    }
    
    // FIXME: - headers
    func requestWithFormData(_ target: requestBaseTypeT, parameters: [String: Any], mimeType: MimeTypes, completion: @escaping RequestCompletionHandler) {
        
        let url = URL(target: target)
        var request = URLRequest(url: url)
        
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.headers
        
        // set contentType boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        if request.allHTTPHeaderFields?["Content-Type"] == nil {
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        }
        
        request.httpBody = createBody(parameters: parameters, boundary: boundary, mimeType: mimeType)
        
        fetchedDataByDataTask(from: request, target: target, completion: completion)
        
    }
 
    
    func createBody(parameters: [String: Any], boundary: String, mimeType: MimeTypes) -> Data {
        // FIXME: - Log use
//        var logString: String = "--\(boundary)\r\n"
        
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            
            if let valueStr = value as? String {
                body.appendString(boundaryPrefix)
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(valueStr)\r\n")
                
                // FIXME: - Log use
                /*logString.append(boundaryPrefix)
                logString.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                logString.append("\(valueStr)\r\n")*/
            } else if let datas = value as? [Data] {
                var i = 0
                
                for data in datas {
                    let fileName = "\(key)\(i).\(mimeType.rawValue)"
                    body.appendString(boundaryPrefix)
                    body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
                    body.appendString("Content-Type: \(mimeType.type)\r\n\r\n")
                    body.append(data)
                    body.appendString("\r\n")
                    
                    // FIXME: - Log use
                    /*logString.append(boundaryPrefix)
                    logString.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
                    logString.append("Content-Type: \(mimeType.type)\r\n\r\n")
                    logString.append(String(data: data, encoding: .utf8) ?? "can't encoding to utf8")
                    logString.append("\r\n")*/
                    
                    i += 1
                }
            }
        }
        
        body.appendString("--".appending(boundary.appending("--")))
        // FIXME: - Log use
        /*logString.append("--".appending(boundary.appending("--")))
        print("""
        \n ----------------------------Body-------------------------
        \n\(logString)
        \n ----------------------------END--------------------------
        """)*/
        return body
    }
    
    /*
    func downloadByDownloadTask(urlString: String, completion: @escaping (Data) -> Void){
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let configiguration = URLSessionConfiguration.default
        configiguration.timeoutIntervalForRequest = .infinity
        
        let urlSession = URLSession(configuration: configiguration, delegate: self, delegateQueue: OperationQueue.main)
        
        let task = urlSession.downloadTask(with: request)
        
        downloadCompletionBlock = completion
        
        task.resume()
    }
    */
    
    // handle response
    private func convertToResult(response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<CommunicatorResponse, NetworkError> {
        
        var prettyString = ""
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data ?? "{ dataEmpty : 'empty' }".data(using: .utf8)!, options: .allowFragments)
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            prettyString = String(data: jsonData, encoding: .utf8) ?? ""
        
        } catch let error {
            prettyString = error.localizedDescription
        }
        
        printLog(logs: [String(describing: response?.statusCode), prettyString], title: "Response")
        
        switch (response, data, error) {
        case let (.some(response), data, .none) :
            let newResponse = CommunicatorResponse(statusCode: response.statusCode, data: data ?? Data())
            return .success(newResponse)
            
        case let (.some(response), _ , .some(error)):
            let result = CommunicatorResponse(statusCode: response.statusCode, data: data ?? Data())
            let error = NetworkError(message: error.localizedDescription, response: result)
            return .failure(error)
            
        case let (_, _ , .some(error)):
            let error = NetworkError(message: error.localizedDescription, response: nil)
            return .failure(error)
            
        default:
            let error = NetworkError(message: NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil).localizedDescription, response: nil)
            return .failure(error)
        }
        
    }

    // MARK: - URLSessionDownload delegate =====================================
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let data = try! Data(contentsOf: location)
        if let block = downloadCompletionBlock {
            block(data)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print(progress)
    }
    
}


extension URLRequest {
 
    mutating func encodeParameters(parameters: [String : String]) {
       
        let parameterArray = parameters.map { (arg) -> String in
            let (key, value) = arg
            return "\(key)=\(self.percentEscapeString(value))"
        }
        
        httpBody = parameterArray.joined(separator: "&").data(using: String.Encoding.utf8)
        httpMethod = "POST"
        setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    }
    
    private func percentEscapeString(_ string: String) -> String {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "-._* ")
        
        return string
            .addingPercentEncoding(withAllowedCharacters: characterSet)!
            .replacingOccurrences(of: " ", with: "+")
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil)
    }
}


// URL extension
public extension URL {
    
    /// Initialize URL from Moya's `TargetType`.
    init<T: RequestBaseType>(target: T) {
        // When a TargetType's path is empty, URL.appendingPathComponent may introduce trailing /, which may not be wanted in some cases
        // See: https://github.com/Moya/Moya/pull/1053
        // And: https://github.com/Moya/Moya/issues/1049
        if target.path.isEmpty {
            self = target.baseURL
        } else {
            self = target.baseURL.appendingPathComponent(target.path)
        }
    }
}

extension Data {
    mutating func appendString(_ string: String) {
        let data = string.data(using: .utf8, allowLossyConversion: false)
        append(data!)
    }
}

func printLog(logs: [String], title: String) {
    print("\n---------------------------\(title)-----------------------------------")
    for log in logs {
        print(log)
    }
    print("-----------------------------END-------------------------------------\n")
}