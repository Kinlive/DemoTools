//
//  RequestBaseType.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/15.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

/// for simulate Moya's protocal and its rquest handle.
public protocol RequestBaseType {
    
    /// The target's base `URL`.
    var baseURL: URL { get }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }
    
    /// The HTTP method used in the request.
    var method: RequestMethod { get }
    
    /// Provides stub data for use in testing.
    var sampleData: Data { get }
    
    /// The type of HTTP task to be performed.
    var task: RequestTasks { get }
    
    /*
    /// The type of validation to perform on the request. Default is `.none`.
    var validationType: ValidationType { get }
    */
    
    /// The headers to be used in the request, default will pass Content-Type json.
    var headers: [String: String]? { get }
}

/*
public extension RequestBaseType {
    
    /// The type of validation to perform on the request. Default is `.none`.
    var validationType: ValidationType {
        return .none
    }
}
*/
