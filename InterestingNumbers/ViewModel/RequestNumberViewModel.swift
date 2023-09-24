//
//  RequestNumberViewModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 24.09.2023.
//

import UIKit
import Combine

class RequestNumberViewModel {
    
    @Published var oneNumberDescription = ChooseNumbers()
    @Published var rangeNumbersDescription: [String:String] = [:]
    
    private let networkManager = NetworkManager()
    private var cancellable: Set<AnyCancellable> = []
    
    func fetchNumber(typeRequest: TypeRequest, _ inputedNumbers: String) {
         let isMath = typeRequest == TypeRequest.random
            
        networkManager.fetchNumber(inputedNumbers, type: ChooseNumbers.self, mathRequest: isMath)
            .sink(receiveValue: { value in
                var numberDescript = value
                numberDescript.typeRequest = typeRequest
                self.oneNumberDescription = numberDescript
            })
            .store(in: &cancellable)
    }
    
    func fetchRangeNumber(_ inputedNumbers: String) {
        networkManager.fetchNumber(inputedNumbers, type: RangeNumbers.self)
            .assign(to: \.rangeNumbersDescription, on: self)
            .store(in: &cancellable)
    }
}

