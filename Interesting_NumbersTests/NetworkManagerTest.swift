//
//  NetworkManagerTest.swift
//  Interesting_NumbersTests
//
//  Created by Yura Sabadin on 05.10.2023.
//

import Combine
import XCTest
@testable import Interesting_Numbers

final class NetworkManagerTests: XCTestCase {
    
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
    
    func testFetchMathNumber() {
        let expectation = XCTestExpectation(description: "Fetch Number")
        
        let numberRequest = "42"
        let mathRequest = true
        
        networkManager?.fetchNumber(numberRequest, type: NumberModel.self, mathRequest: mathRequest)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Expected successful fetch, but got error: \(error)")
                }
            }, receiveValue: { result in
                XCTAssertNotNil(result.text)
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        wait(for: [expectation], timeout: 45.0)
    }
    
    func testErrorFetchNumber() {
        let expectation = XCTestExpectation(description: "Fetch NumberError")
        
        let numberRequest = "Four"  // Should be "4"
        let mathRequest = true
        let errorString = "The data couldn’t be read because it isn’t in the correct format."
        
        networkManager?.fetchNumber(numberRequest, type: NumberModel.self, mathRequest: mathRequest)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error.localizedDescription, "Yura")
                    XCTAssertTrue(!error.localizedDescription.isEmpty)
                    XCTAssertEqual(error.localizedDescription, errorString)
                    
                    expectation.fulfill()
                }
            }, receiveValue: { _ in
                
            })
            .store(in: &cancellable)
        
        wait(for: [expectation], timeout: 5.0)
    }
}
