//
//  CustomFileManager.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/24.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

class CustomFileManager {

    /// ~/Documents/
    static let mainDocPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    ///
    static func appendingPath(file: URL, needDirectories directory: String? = nil) -> URL {
        
        var firstPath: URL = mainDocPath
        
        if let folderName = directory {
            
            firstPath = mainDocPath.appendingPathComponent(folderName)
            do {
                try FileManager.default.createDirectory(at: firstPath, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                printLog(logs: [error.localizedDescription], title: "CustomFileManager-appendingPath")
            }
        }
        
        return firstPath.appendingPathComponent(file.lastPathComponent)
    }
    
    /// Load file from userDomain documents.
    ///
    /// - Parameter path: if not any folder on it just nil, can be nested path like as */aaaaa/bbbbb/ccccc*.
    static func loadFile(withDirectory path: String? = nil) -> [URL] {
        
        var atPath: URL = mainDocPath
        
        if let foundUrl = path {
             atPath.appendPathComponent(foundUrl)
        }
        
        var allPaths: [URL] = []
        do {
            allPaths = try FileManager.default.contentsOfDirectory(at: atPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
        } catch let error {
            printLog(logs: [error.localizedDescription], title: "loadFile error")
            return []
        }
        
        let allPathsStr: [String] = allPaths.map { $0.absoluteString }
        printLog(logs: allPathsStr, title: "GetPaths")

        return allPaths
    }
    
    /// Save file to the userDomain documents
    ///
    /// - Parameter fromUrl: where the file path.
    /// - Parameter destination: give full path from ~/, or can use **CustomFileManager.appendingPath(file: needDirectioies:)** to combine needs path.
    /// - Parameter completion: destinationUrl, isSaved, error.
    static func saveFiles(fromUrl: URL, to destination: URL, completion: (URL, Bool, Error?) -> Void) {
        try? FileManager.default.removeItem(at: destination)
        
        do {
            try FileManager.default.copyItem(at: fromUrl, to: destination)
            
            completion(destination, true, nil)
        } catch let error {
            printLog(logs: [error.localizedDescription], title: "File Save Error")
            completion(destination, false, error)
        }
        
    }
    
}
