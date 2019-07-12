//
//  DemoSignatureUITests.swift
//  DemoSignatureUITests
//
//  Created by Thinkpower on 2019/7/8.
//  Copyright © 2019 Thinkpower. All rights reserved.
//

import XCTest

class DemoSignatureUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTapTabbar() {
        
        let tabBarsQuery = XCUIApplication().tabBars
        tabBarsQuery.buttons["Signature"].tap()
        tabBarsQuery.children(matching: .button).matching(identifier: "Item").element(boundBy: 0).tap()
        tabBarsQuery.children(matching: .button).matching(identifier: "Item").element(boundBy: 1).tap()
        tabBarsQuery.buttons["Snapshot"].tap()
        
    }

    func testSignature() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Signature"].tap()
        app.buttons["sign"].tap()
        XCUIDevice.shared.orientation = .landscapeRight
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element
        element.swipeRight()
        element.swipeUp()
        element.tap()
        element.swipeRight()
        element.swipeUp()
        element.swipeUp()
        element.swipeRight()
        element/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element.tap()
        element.tap()
        element.swipeUp()
        element/*@START_MENU_TOKEN@*/.swipeRight()/*[[".swipeUp()",".swipeRight()"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element.swipeRight()
        element.swipeUp()
        app.buttons["確認"].tap()
        XCUIDevice.shared.orientation = .portrait
        
    }
    
    func testTapDynamic() {
        
        let app = XCUIApplication()
        app.tabBars.children(matching: .button).matching(identifier: "Item").element(boundBy: 0).tap()
        
        let emptyListTable = app.tables["Empty list"]
        emptyListTable.otherElements["第一行"].buttons["展開"].tap()
        
        let tablesQuery2 = app.tables
        let tablesQuery = tablesQuery2
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["1-3"]/*[[".cells.staticTexts[\"1-3\"]",".staticTexts[\"1-3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["收起"]/*[[".otherElements[\"第一行\"].buttons[\"收起\"]",".buttons[\"收起\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        emptyListTable.otherElements["第二行"].buttons["展開"].tap()
        tablesQuery2.otherElements["第三行"].buttons["展開"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["3-4"]/*[[".cells.staticTexts[\"3-4\"]",".staticTexts[\"3-4\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        tablesQuery2.otherElements["第四行"].staticTexts["展開"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["4-5"]/*[[".cells.staticTexts[\"4-5\"]",".staticTexts[\"4-5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        tablesQuery.otherElements["第三行"].swipeRight()
        tablesQuery/*@START_MENU_TOKEN@*/.otherElements["第一行"].staticTexts["展開"]/*[[".otherElements[\"第一行\"].staticTexts[\"展開\"]",".staticTexts[\"展開\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        if tablesQuery.staticTexts["1-5"].exists {
            tablesQuery.staticTexts["1-5"].swipeRight()
        }
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["2-1"]/*[[".cells.staticTexts[\"2-1\"]",".staticTexts[\"2-1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        
        tablesQuery.otherElements["第三行"].staticTexts["收起"].tap()
        tablesQuery.otherElements["第二行"].buttons["收起"].tap()
        
        tablesQuery2/*@START_MENU_TOKEN@*/.buttons["收起"]/*[[".otherElements[\"第一行\"].buttons[\"收起\"]",".buttons[\"收起\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery2/*@START_MENU_TOKEN@*/.buttons["收起"]/*[[".otherElements[\"第四行\"].buttons[\"收起\"]",".buttons[\"收起\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
    }
    
    func testPageScroll() {
        
        let app = XCUIApplication()
        app.tabBars.children(matching: .button).matching(identifier: "Item").element(boundBy: 1).tap()
        
        let page2Button = app.buttons["Page2"]
        page2Button.tap()
        app.buttons["Page1"].tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.tables.staticTexts["Get 1-2"]/*[[".cells.tables",".cells.staticTexts[\"Get 1-2\"]",".staticTexts[\"Get 1-2\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.swipeLeft()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.tables.staticTexts["Get 2-6"]/*[[".cells.tables",".cells.staticTexts[\"Get 2-6\"]",".staticTexts[\"Get 2-6\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.swipeRight()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.tables.staticTexts["Get 1-4"]/*[[".cells.tables",".cells.staticTexts[\"Get 1-4\"]",".staticTexts[\"Get 1-4\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.swipeUp()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.tables.staticTexts["Get 1-7"]/*[[".cells.tables",".cells.staticTexts[\"Get 1-7\"]",".staticTexts[\"Get 1-7\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.swipeUp()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.tables.staticTexts["Get 2-2"]/*[[".cells.tables",".cells.staticTexts[\"Get 2-2\"]",".staticTexts[\"Get 2-2\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.swipeDown()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.tables/*[[".cells.tables",".tables"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .cell).element(boundBy: 1).staticTexts["Get 1-2"].swipeDown()
        page2Button.tap()
        
        let get32StaticText = collectionViewsQuery/*@START_MENU_TOKEN@*/.tables.staticTexts["Get 3-2"]/*[[".cells.tables",".cells.staticTexts[\"Get 3-2\"]",".staticTexts[\"Get 3-2\"]",".tables"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/
        get32StaticText.swipeUp()
        
    }
}
