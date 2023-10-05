//
//  InterestingNumbersUITests.swift
//  InterestingNumbersUITests
//
//  Created by Yura Sabadin on 02.10.2023.
//

import XCTest

@testable import Interesting_Numbers

final class InterestingNumbersUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        app.launch()
        logOut()
    }
    
    func testWorkAppAsGuest() {
        let tryGuestButton = app.buttons["Try as Guest"]
        
        guard tryGuestButton.exists else {
            XCTFail("Warning Error tryGuestButton not exists")
            return}
        
        let elementsQuery = app.scrollViews.otherElements
        let userNumberButton = elementsQuery.staticTexts["User  number"]
        let userNumber = app.staticTexts["User  number"]
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: userNumber)
        let textField = elementsQuery.textFields["Input number like 45"]
        let displayFactButton = elementsQuery/*@START_MENU_TOKEN@*/.staticTexts["Display Fact"]/*[[".buttons[\"Display Fact\"].staticTexts[\"Display Fact\"]",".staticTexts[\"Display Fact\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        let closeDescriptionButton = app.navigationBars["Interesting_Numbers.DescriptionNumberView"].buttons["X Circle"]
        let userNavigationButton = app.navigationBars["Interesting_Numbers.ChoiseRequestNumbersView"].buttons["userButton"]
        
        tryGuestButton.tap()
        
        wait(for: [expectation], timeout: 10)
        
        XCTAssert(userNumberButton.exists)
        
        userNumberButton.tap()
        textField.tap()
        textField.typeText("56")
        app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        XCTAssert(displayFactButton.exists)
        
        displayFactButton.tap()
        
        XCTAssert( closeDescriptionButton.exists)
        
        closeDescriptionButton.tap()
        
        XCTAssert(userNavigationButton.exists)
        
        userNavigationButton.tap()
        
        XCTAssert(app.children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 0)/*@START_MENU_TOKEN@*/.otherElements["PopoverDismissRegion"]/*[[".otherElements[\"dismiss popup\"]",".otherElements[\"PopoverDismissRegion\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        
        logOutButtonTap()
        
        XCTAssert(tryGuestButton.exists)
    }
    
    func testSignUpEnterAppWithDefaultUser() {
        
        app.buttons["LOG IN"].tap()
        
        let elementsQuery = app.scrollViews.otherElements
        let element = elementsQuery.containing(.button, identifier:"Forgot Password?").children(matching: .other).element(boundBy: 1)
        let emailTextField = element.children(matching: .textField).element
        let passwordTextField = element.children(matching: .secureTextField).element
        let randomNumberButton = elementsQuery/*@START_MENU_TOKEN@*/.staticTexts["Random  number"]/*[[".buttons[\"Random  number\"].staticTexts[\"Random  number\"]",".staticTexts[\"Random  number\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        
        emailTextField.tap()
        emailTextField.typeText("test@test.com")
        
        passwordTextField.tap()
        passwordTextField.typeText("123456")
        app/*@START_MENU_TOKEN@*/.buttons["Return"]/*[[".keyboards",".buttons[\"return\"]",".buttons[\"Return\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        XCTAssert( elementsQuery.buttons["LOG IN"].exists)
        elementsQuery.buttons["LOG IN"].tap()
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: randomNumberButton)
    
        wait(for: [expectation], timeout: 10)
        randomNumberButton.tap()
        elementsQuery/*@START_MENU_TOKEN@*/.staticTexts["Display Fact"]/*[[".buttons[\"Display Fact\"].staticTexts[\"Display Fact\"]",".staticTexts[\"Display Fact\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Interesting_Numbers.DescriptionNumberView"].buttons["X Circle"].tap()
                
        logOutButtonTap()
    }
    
    private func logOut() {
        let userNavigationButton = app.navigationBars["Interesting_Numbers.ChoiseRequestNumbersView"].buttons["userButton"]
        guard userNavigationButton.exists else {return}
        userNavigationButton.tap()
        
        logOutButtonTap()
    }
    
    private func logOutButtonTap() {
        let logOutButton =  app.buttons["Log Out"]
        if logOutButton.exists {
            logOutButton.tap()
        }
    }
}
