//
//  SQLiteColumnInserter.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/29.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation

enum SQLiteOperators {
//    case all
    case and
    case any
    case between
    case exists
    case `in`
    case like(as: String)
    case not
    case or
    //  = , != , < , > , <= , >=
    case equal
    case notEqual
    case lessThan
    case greatThan
    case lessOrEqual
    case greatOrEqual
    
    case orderBy(column: String, arrange: Arrange)
    case limit
    
    enum Arrange: String {
        case asc = "ASC"
        case desc = "DESC"
    }
}

extension SQLiteOperators {
    var symbol: String {
        switch self {
//        case .all:            return "ALL"
        case .and:            return "AND"
        case .any:            return "ANY"
        case .between:        return "BETWEEN"
        case .exists:         return "EXISTS"
        case .in:             return "IN"
        case .like(let value): return "LIKE '%\(value)%'"
        case .not:            return "NOT"
        case .or:             return "OR"
        case .equal:          return "="
        case .notEqual:       return "!="
        case .lessThan:       return "<"
        case .greatThan:      return ">"
        case .lessOrEqual:    return "<="
        case .greatOrEqual:   return ">="
        case .orderBy(let column, let arrange): return "ORDER BY \(column) \(arrange.rawValue)"
        case .limit: return "LIMIT"
        }
    }
}

enum SQLiteConditions {
    case wheres(column: String?, condition: SQLiteOperators, beCompared: String?)
    
    var group: String {
        let whiteSpace = " "
        var text: String = ""
        
        switch self {
        case .wheres(let column, let condition, let beCompared):
            if let col = column {
                text.append(col + whiteSpace)
            }
            // =
            text += condition.symbol
            
            if let compared = beCompared {
                if let _ = Double(compared) {
                    text += whiteSpace + compared
                } else {
                    text += whiteSpace + "'" + compared + "'" // 'becompared'
                }
            }
            
        }
        return text
    }
}

enum SQLiteColumnInserter {
    
    case int(column: String, value: Int)
    case text(column: String, value: String)
    case real(column: String, value: Double)
    
}

extension SQLiteColumnInserter {
    
    var column: String {
        switch self {
        case .int(let name, _):  return name
        case .text(let name, _): return name
        case .real(let name, _): return name
            
        }
    }
    
    var value: String {
        switch self {
        case .int(_, let value):  return "\(value)"
        case .text(_, let value): return "'\(value)'"
        case .real(_, let value): return "\(value)"
        }
    }
    
}

enum SQLiteAction {
    
    var whiteSpace: String { return " " }
    
    case insert(tableName: String, columnValue: [SQLiteColumnInserter])
    case select(columns: [String]?, fromTable: String, wheres: [SQLiteConditions]?)
    case update
    case delete
    
}

extension SQLiteAction {
    var statementString: String {
        
        var stmtStr: String = ""
        
        switch self {
        case .insert(let tableName, let columnValue):
            stmtStr = "INSERT INTO \(tableName) ("
            
            // append need inserts columns name
            for (i, value) in columnValue.enumerated() {
                stmtStr.append((i != columnValue.count - 1) ? value.column + ", " : "\(value.column)) VALUES(")
            }
            
            // append inserts columns value
            for (i, value) in columnValue.enumerated() {
                stmtStr.append((i != columnValue.count - 1) ? value.value + ", " : value.value + ");")
            }
            
        case .select(let columns, let tableName, let wheres):
            // SELECT Columns name FROM tableName WHERE
            stmtStr = "SELECT"
            
            // append columns.
            if let col = columns {
                col.forEach { stmtStr += $0 + ", " }
                if stmtStr.last == " " { stmtStr.removeLast() }
                if stmtStr.last == "," { stmtStr.removeLast() }
                stmtStr += whiteSpace
            } else {
                stmtStr += whiteSpace + "*" + whiteSpace
            }
            
            // append table name.
            stmtStr.append("FROM" + whiteSpace + tableName + whiteSpace)
            
            // append if had where conditions or not
            if var conditions = wheres {
                // arrange the case .orderBy to last
                var moveIndex: Int = 0
                for (i, condition) in conditions.enumerated() {
                    if case .wheres(_, let condition, _) = condition,
                        case .orderBy = condition {
                        moveIndex = i
                        break
                    }
                }
                let beMoving = conditions.remove(at: moveIndex)
                conditions.append(beMoving)
                
                // arrange the case .limit to last
                var move2Index: Int = 0
                for (i, condition) in conditions.enumerated() {
                    if case .wheres(_, let condition, _) = condition,
                        case .limit = condition {
                        move2Index = i
                        break
                    }
                }
                let beMoving2 = conditions.remove(at: move2Index)
                conditions.append(beMoving2)
                
                stmtStr.append("WHERE")
                for (i, condition) in conditions.enumerated() {
                    stmtStr.append(whiteSpace + condition.group)
                    if i != conditions.count - 1 {
                        // FIXME: - ORDER 跟 limit 不用加AND連接.
                        stmtStr.append(whiteSpace + SQLiteOperators.and.symbol)
                    }
                }
            }
            
        case .update:
            
            return "UPDATE "
        case .delete:
            
            return "DELETE FROM "
        }
        
        stmtStr.append(";")
        return stmtStr
    }
}

extension Array {
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        
        return arr
    }
    
}
