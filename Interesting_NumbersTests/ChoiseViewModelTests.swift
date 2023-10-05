//
//  ChoiseViewModelTests.swift
//  InterestingNumbersTests
//
//  Created by Yura Sabadin on 01.10.2023.
//

import XCTest
import Combine
@testable import Interesting_Numbers

final class ChoiseRequestNumberViewModelTests: XCTestCase {
    
    var choiseRequestViewModel: ChoiseRequestNumberViewModel?
    var cancellable = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        choiseRequestViewModel = ChoiseRequestNumberViewModel()
    }
    
    override func tearDown() {
        choiseRequestViewModel = nil
        cancellable.removeAll()
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
    
    func testFetchRangeNumbersViewModel() {
        
        let expectation = XCTestExpectation(description: "Fetch RangeNumberViewModel")

        choiseRequestViewModel?.fetchRangeNumber("10..15", completionError: { error in
            XCTFail("Expected successful fetch, but got error: \(error)")
        })
        
        choiseRequestViewModel?.$rangeNumbersDescription
            .filter{ !$0.isEmpty }
            .sink(receiveValue: { value in
                
                XCTAssert( value.count > 2 )
                XCTAssertFalse(value.isEmpty)
                XCTAssertEqual(value.keys.count, 6)
                
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        wait(for: [expectation], timeout: 5.0)
    }
}

