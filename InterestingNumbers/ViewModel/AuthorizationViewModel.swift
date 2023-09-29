//
//  AuthorizationViewModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 15.09.2023.
//

import Foundation
import Combine

final class AuthorizationViewModel {
    
    private let authManager: AuthorizationService
    private var cancellable = Set<AnyCancellable>()
    
    @Published var name: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var isBusyEmail: Bool = false
    
    var logInIsEnable: AnyPublisher<Bool,Never> {
        return Publishers.CombineLatest($email,$password)
            .map{email, password in
                let isValidEmail = !email.isEmpty && email.contains("@")
                let isValidPassword = password.count > 5 && !password.isEmpty
                return isValidEmail && isValidPassword
            }
            .eraseToAnyPublisher()
    }
    
    var registerIsEnable: AnyPublisher<Bool,Never> {
        return Publishers.CombineLatest3($isBusyEmail, $name, logInIsEnable)
            .map{isBusyEmail, name, loginnable in
                let isValidName = !name.isEmpty
                return loginnable && isValidName && !isBusyEmail
            }
            .eraseToAnyPublisher()
    }
    
    init(authService: AuthorizationService) {
        self.authManager = authService
        checkMailIsBusy()
    }
    
    func checkMailIsBusy() {
        $email
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter{!$0.isEmpty && $0.contains("@") && $0.contains(".")}
            .sink { email in
                self.authManager.checkEmailIsBusy(email: email) { self.isBusyEmail = $0 }
            }.store(in: &cancellable)
    }
}
