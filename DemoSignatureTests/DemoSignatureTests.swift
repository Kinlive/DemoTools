//
//  DemoSignatureTests.swift
//  DemoSignatureTests
//
//  Created by Thinkpower on 2019/7/8.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import XCTest
@testable import DemoSignature

class DemoSignatureTests: XCTestCase {

    let testVC = PracticeMVVMViewController()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let viewModel = AlbumListViewModel(delegate: testVC)
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        testVC.viewDidLoad()
        

    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
