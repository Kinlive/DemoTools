//
//  SQLiteHelper.swift
//  DemoSignature
//
//  Created by Thinkpower on 2019/7/25.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import Foundation
import SQLite3

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

extension SQLiteError {
    var message: String {
        switch self {
        case .OpenDatabase(let msg): return msg
        case .Prepare(let msg) : return msg
        case .Step(let msg): return msg
        case .Bind(let msg): return msg
        }
    }
}

enum SQLiteSuccess {
    case openDatabase
    case createTable
}

class SQLiteHelper {
    
    typealias SQLiteCompletion = (Result<Any?, SQLiteError>) -> Void
    
    static let `default` = SQLiteHelper()
    private var db: OpaquePointer?
    let dbName = "testDB.db"
    
    let tableName = "Contact"
    
    let createTableString =
    """
    CREATE TABLE Contact(
    Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    Name CHAR(255));
    """
    
    let insertStatementString =
    """
    INSERT INTO Contact (Id, Name) VALUES(?, ?);
    """
    
    let queryStatementString = "SELECT * FROM Contact;"
    
    let updateStatementString =
    """
    UPDATE Contact SET Name = 'Chris' WHERE Id = 1;
    """
    
    let deleteStatementString = "DELETE FROM Contact WHERE Id = 1;"
    
    private var cacheTables: [String : [SQLiteColumnCreater]] = [:]
    
    private func errorMsg(db: OpaquePointer) -> String {
        return String(cString: sqlite3_errmsg(db))
    }
    
    func openDatabase() -> Bool {
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(dbName)

        if sqlite3_open(path.path, &db) == SQLITE_OK {
            return true
            
        } else {
            return false
        }
        
    }
    
    func openDb(completion: SQLiteCompletion) -> Bool {
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(dbName)
        
        if sqlite3_open(path.path, &db) == SQLITE_OK {
            printLog(logs: [path.path], title: "Open db on: ")
//            completion(.success(nil)) // FIXME: - add SQLiteSuccess openDB
            return true
            
        } else {
            completion(.failure(SQLiteError.OpenDatabase(message: errorMsg(db: db!))))
            return false
        }
        
    }
    
    /// create table OK use.
    func createTable(tableName: String, columns: [SQLiteColumnCreater], completion: SQLiteCompletion) {
        
        guard openDb(completion: completion), let db = db else { return }
        
        var statement: OpaquePointer?
        
        defer {
            if statement != nil {
                sqlite3_finalize(statement)
            }
            sqlite3_close(db)
        }
        
        var queryString: String = "CREATE TABLE \(tableName)("

        // handle string of columns
        columns.forEach {
           queryString += $0.group + ", "
        }
        
        if queryString.last!.isWhitespace {
            queryString.removeLast()
        }
        
        if queryString.last == "," {
            queryString.removeLast()
        }
        
        queryString += ");"
        
        printLog(logs: [queryString], title: "Create table")
        
        // prepare create table -1 means read/write max limits be infinity.
        guard sqlite3_prepare_v2(db, queryString, -1, &statement, nil) == SQLITE_OK else {
            completion(.failure(SQLiteError.Prepare(message: errorMsg(db: db))))
            return
        }
        
        // action create table
        guard sqlite3_step(statement) == SQLITE_DONE else {
            completion(.failure(SQLiteError.Step(message: errorMsg(db: db))))
            return
        }
        
        cacheTables[tableName] = columns
        
        // create table successful.
        completion(.success(nil))
    }
    
    /*func createTable() {
        
        guard openDatabase(), let db = db else { return }
        var createTableStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                // Table create
                print("Table create successful")
            } else {
                // table could not be create
            }
        } else {
            // create table statement could not be prepared
        }
        
        // must call finalize every
        sqlite3_finalize(createTableStatement)
        
        sqlite3_close(db)
    } */
    
    func insert(action: SQLiteAction, completion: SQLiteCompletion) {
        guard openDb(completion: completion), let db = db else { return }
        var statement: OpaquePointer?
        
        defer {
            if statement != nil {
                sqlite3_finalize(statement)
            }
            sqlite3_close(db)
        }
        
        let queryString: String = action.statementString
        
        guard sqlite3_prepare_v2(db, queryString, -1, &statement, nil) == SQLITE_OK else {
            completion(.failure(SQLiteError.Prepare(message: errorMsg(db: db))))
            return
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else { completion(.failure(SQLiteError.Step(message: errorMsg(db: db)))); return }
        
        completion(.success(nil))
        return
    }
    
    /*func insert() {
        
        guard openDatabase(), let db = db else { return }
        
        var insertStmt: OpaquePointer?
        
        // The first parameter of the function is the statement to bind to, while the second is a non-zero based index for the position of the ? you’re binding to. The third and final parameter is the value itself. This binding call returns a status code, but for now you assume that it succeeds;
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStmt, nil) == SQLITE_OK {
            let id: Int32 = 1
            let name = "Ray"
            
            sqlite3_bind_int(insertStmt, 1, id)
            sqlite3_bind_text(insertStmt, 2, name, -1, nil)
            
            // Use the sqlite3_step() function to execute the statement and verify that it finished
            if sqlite3_step(insertStmt) == SQLITE_DONE {
                // Insert row successful
                print("Insert row successful")
            } else {
                // Could not insert row
                
            }
            
        } else {
            // INSERT statement could not be prepared.
            
        }
        
        sqlite3_finalize(insertStmt)
        
        sqlite3_close(db)
    }*/
    
    
    // for insert array use
    func forArraysInsert(arrays: [String] ) {
        guard openDatabase(), let db = db else { return }
        
        var insertStmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStmt, nil) == SQLITE_OK {
            for (_, value) in arrays.enumerated() {
//                let id: Int32 = Int32(i) + 1
                let name = value
                
//                sqlite3_bind_int(insertStmt, 1, id)
                sqlite3_bind_text(insertStmt, 2, name, -1, nil)
                if sqlite3_step(insertStmt) == SQLITE_DONE {
                    // Insert row successful
                    print("Insert ROWS successful")
                } else {
                    // Could not insert row
                    
                }
                
                // As a hint, you’ll need to reset your compiled statement back to its initial state by calling sqlite3_reset() before you execute it again.
                sqlite3_reset(insertStmt)
            }
            
            sqlite3_finalize(insertStmt)
        
        } else {
            
        }
        
        sqlite3_close(db)
        
    }
    
    // QUERY
    func query() {
        guard openDatabase(), let db = db else { return }
        var queryStmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStmt, nil) == SQLITE_OK {
            
            if sqlite3_step(queryStmt) == SQLITE_ROW {
                // The first column is an Int, so you use sqlite3_column_int() and pass in the statement and a zero-based column index.
                let id = sqlite3_column_int(queryStmt, 0)
                
                let queryResultCol1 = sqlite3_column_text(queryStmt, 1)
                
                let name = String(cString: queryResultCol1!)
                
                print("Query with: \(id) and \(name)")
                
            } else {
                // no results.
            }
            
        } else {
            
        }
        
        sqlite3_finalize(queryStmt)
        sqlite3_close(db)
    }
    
    func queryAll(action: SQLiteAction) {
        guard openDatabase(), let db = db else { return }
        var queryStmt: OpaquePointer?
        
        // if need get all value from db.
        if sqlite3_prepare_v2(db, action.statementString, -1, &queryStmt, nil) == SQLITE_OK {
         
            while sqlite3_step(queryStmt) == SQLITE_ROW {
                // The first column is an Int, so you use sqlite3_column_int() and pass in the statement and a zero-based column index.
                let id = sqlite3_column_int(queryStmt, 0)
                
                let queryResultCol1 = sqlite3_column_text(queryStmt, 1)
                
                let name = String(cString: queryResultCol1!)
                
                print("Query with: \(id) and \(name)")
            }
        } else {
            
        }
        
        sqlite3_finalize(queryStmt)
        sqlite3_close(db)
        
    }
    
    // Update
    func update() {
        guard openDatabase(), let db = db else { return }
        
        var updateStmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStmt, nil) == SQLITE_OK {
            
            if sqlite3_step(updateStmt) == SQLITE_DONE {
                // success
                print("update row successful")
            } else {
                
            }
            
        } else {
            
        }
        
        sqlite3_finalize(updateStmt)
        sqlite3_close(db)
    }
    
    func delete(action: SQLiteAction) {
        guard openDatabase(), let db = db else { return }
        
        var deleteStmt: OpaquePointer?
        if sqlite3_prepare_v2(db, action.statementString, -1, &deleteStmt, nil) == SQLITE_OK {
            
            if sqlite3_step(deleteStmt) == SQLITE_DONE {
                print("Delete row successful")
            } else {
                
            }
        } else {
            
        }
        
        sqlite3_finalize(deleteStmt)
        
        sqlite3_close(db)
    }
    
    
}
