//
//  DemoRequestType.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/16.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

enum DemoRequest {
    case get
    case post
    case headersWithGet
    case headersWithPost
    case json
    case postAnthingParams(params: [String : Any])
    case postAnythingHeaders
    case postAnythingUrlEncoded(params: [String : Any])
    case postFormdata(datas: [String: Any], mimeType: MimeTypes)
    
    var name: String {
        switch self {
        case .get:                    return "get"
        case .post:                   return "post"
        case .headersWithGet:         return "headersWithGet"
        case .headersWithPost:        return "headersWithPost"
        case .json:                   return "json"
        case .postAnthingParams:      return "postAnthingParams"
        case .postAnythingHeaders:    return "postAnythingHeaders"
        case .postAnythingUrlEncoded: return "postAnythingUrlEncoded"
        case .postFormdata:       return "postFormdata"
        }
    }
}

extension DemoRequest: RequestBaseType {
    var baseURL: URL {
        return URL(string: "https://httpbin.org/")!
    }
    
    var path: String {
        switch self {
        case .get:               return "get"
        case .post:              return "post"
        case .headersWithGet:    return "headers"
        case .headersWithPost:   return "response-headers"
        case .json:              return "json"
        case .postAnthingParams: return "anything"
        case .postAnythingHeaders: return "anything"
        case .postAnythingUrlEncoded: return "anything"
        case .postFormdata: return "anything"
        }
    }
    
    var method: RequestMethod {
        switch self {
        case .get, .headersWithGet, .json:
            return RequestMethod.get

        case .post, .headersWithPost, .postAnythingHeaders, .postAnthingParams, .postAnythingUrlEncoded, .postFormdata:
            return RequestMethod.post
        }
    }
    
    var sampleData: Data {
        return "{}".data(using: .utf8)!
    }
    
    var task: RequestTasks {
        
        switch self {
        case .get:
            return .requestPlain
            
        case .headersWithGet:
            return .requestPlain
            
        case .headersWithPost:
            return .requestPlain
            
        case .json:
            return .requestPlain
            
        case .post:
            return .requestParameters(parameters: ["aaaaaa" : "vavavava1", "bbbbbbb" : "vavavavav2"])
        
        case .postAnthingParams(let params):
            return .requestJSONBody(parameters: params)
            
        case .postAnythingHeaders:
            return .requestPlain
            
        case .postAnythingUrlEncoded(let params):
            return .requestURLEncodedBody(parameters: params)
            
        case .postFormdata(let datas, let mimeType):
            return .requestmultipartFormdata(parameters: datas, mimeType: mimeType)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .postAnythingHeaders:
            return ["token" : "ABI9f823mF30g", "tokenB" : "jw023mv93j5t930", "tokenC": "iefj209mbitjb04"]
        default:
            return nil
        }
    }
    
    
}
