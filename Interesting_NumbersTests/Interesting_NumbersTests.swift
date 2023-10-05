//
//  Interesting_NumbersTests.swift
//  Interesting_NumbersTests
//
//  Created by Yura Sabadin on 01.10.2023.
//

import Combine
import XCTest
@testable import Interesting_Numbers

final class Interesting_NumbersTests: XCTestCase {
    
    var networkManager: NetworkManager?
    var cancellable = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        networkManager = NetworkManager()
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }
    
    
    func testFetchNumber() {
        let expectation = XCTestExpectation(description: "Fetch Number")
        
        let numberRequest = "42"
        let mathRequest = true
        
        networkManager?.fetchNumber(numberRequest, type: ChooseNumbers.self, mathRequest: mathRequest)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Expected successful fetch, but got error: \(error)")
                }
                expectation.fulfill()
            }, receiveValue: { result in
                XCTAssertNotNil(result.text)
            })
            .store(in: &cancellable)
        
        wait(for: [expectation], timeout: 5.0)
    }
}


