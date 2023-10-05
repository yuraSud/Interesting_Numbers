//
//  ChoiseViewModelTests.swift
//  InterestingNumbersTests
//
//  Created by Olga Sabadina on 01.10.2023.
//

import XCTest
import Combine
@testable import Interesting_Numbers

final class ChoiseViewModelTests: XCTestCase {
    
    var choiseRequestViewModel: ChoiseRequestNumberViewModel?
    var cancellable = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        choiseRequestViewModel = ChoiseRequestNumberViewModel()
    }
    
    override func tearDown() {
        choiseRequestViewModel = nil
        super.tearDown()
    }
    
    func testFetchNumberViewModel() {
        
        let expectation = XCTestExpectation(description: "Fetch NumberViewModel")
       
        choiseRequestViewModel?.fetchNumber(typeRequest: .year, "4/23", completionError: { error in
            XCTFail("Expected successful fetch, but got error: \(error)")
        })
        
        choiseRequestViewModel?.$oneNumberDescription
            .filter{$0.type != nil }
            .sink(receiveValue: { value in
                let answerFromServer = value.text ?? ""
                let firstWord = answerFromServer.prefix(5)
                XCTAssertNotNil(value.text)
                XCTAssert(!answerFromServer.isEmpty)
                XCTAssertEqual(firstWord, "April")
                expectation.fulfill()
                
            })
            .store(in: &cancellable)
        
        wait(for: [expectation], timeout: 15.0)
    }
}

