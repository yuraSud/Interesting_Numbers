//
//  AuthorizationViewModelTest.swift
//  InterestingNumbersTests
//
//  Created by Yura Sabadin on 01.10.2023.
//

import XCTest
import Combine
@testable import Interesting_Numbers

final class AuthorizationViewModelTest: XCTestCase {
    
    let authService = AuthorizationService.shared
    var authorizedViewModel: AuthorizationViewModel?
    var cancellable = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        authorizedViewModel = AuthorizationViewModel(authService: authService)
    }
    
    override func tearDown() {
        authorizedViewModel = nil
        cancellable.removeAll()
        super.tearDown()
    }
    
    func testAuthorizedViewModel() {
        var isLoginEnable = false
        var emailIsBusy = false
        
        let expectation = XCTestExpectation(description: "Fetch NumberViewModel")
        
        authorizedViewModel?.name = "test"
        authorizedViewModel?.password = "123456"
        authorizedViewModel?.email = "test@test.com"
        
        authorizedViewModel?.$isBusyEmail
            .sink(receiveValue: { isBusy in
                emailIsBusy = isBusy
            })
            .store(in: &cancellable)
        
        authorizedViewModel?.logInIsEnable
            .sink(receiveValue: { isLoginIn in
                isLoginEnable = isLoginIn
            })
            .store(in: &cancellable)
        
        authorizedViewModel?.registerIsEnable
            .debounce(for: 2, scheduler: DispatchQueue.main)
            .sink(receiveValue: { isCanRegister in

                XCTAssert(isLoginEnable) //Login and Password -> true
                XCTAssertFalse(emailIsBusy) // email "test@test.com" - isBusy -> true
                XCTAssert(isCanRegister) //register can`t possible, because email is busy
                
                expectation.fulfill()
            })
            .store(in: &cancellable)
        
        wait(for: [expectation], timeout: 15.0)
    }
}
