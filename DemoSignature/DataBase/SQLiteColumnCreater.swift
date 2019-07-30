//
//  SQLiteColumnCreater.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/26.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

enum SQLiteColumnCreater {
    
    var whiteSpace: String { return " " }
    
    /// Use on id or any integer value, and *bool* value false would be 0 to saved.
    case int(name: String, asPrimaryKey: Bool, notNull: Bool, autoIncrement: Bool)
    
    /// Use on any text value or like as date string.
    case text(name: String, notNull: Bool)
    
    /// Use on double or float value.
    case real(name: String, notNull: Bool)
    
    /// It would be saved on non change to others type
    case none(name: String)
    
}

extension SQLiteColumnCreater {
    
    var type: String {
        switch self {
        case .int:  return "INTEGER"
        case .text: return "TEXT"
        case .real: return "REAL"
        case .none: return "NONE"
        }
    }
    
    /// groups all needs for sql use on one column.
    var group: String {
        
        var queryString: String = ""
        
        switch self {
        case .int(let name, let asPrimaryKey, let notNull, let autoIncrement):
            let optionKey: String = asPrimaryKey ? whiteSpace + "PRIMARY KEY" : ""
            let optionNotNull: String = notNull ? whiteSpace + "NOT NULL" : ""
            let optionAutoIncrement: String = autoIncrement ? whiteSpace + "AUTOINCREMENT" : ""
            
            queryString = name + whiteSpace + self.type +
                            optionKey + optionAutoIncrement + optionNotNull
 
        case .text(let name, let notNull):
            let options: String = notNull ? whiteSpace + "NOT NULL" : ""
            
            queryString = name + whiteSpace + self.type + options
    
        case .real(let name, let notNull):
            let options: String = notNull ? whiteSpace + "NOT NULL" : ""
            
            queryString = name + whiteSpace + self.type + options
            
        case .none(let name):
           
            queryString = name + whiteSpace + self.type
        
        }
        
        return queryString
    }
    
}
