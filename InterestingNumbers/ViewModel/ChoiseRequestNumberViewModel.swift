//
//  RequestNumberViewModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 24.09.2023.
//

import UIKit
import Combine

final class ChoiseRequestNumberViewModel {
    
    @Published var oneNumberDescription = NumberModel()
    @Published var rangeNumbersDescription: [String:String] = [:]
    
    private let networkManager = NetworkManager()
    private var cancellable: Set<AnyCancellable> = []
    
    func fetchNumber(typeRequest: TypeRequest, _ inputedNumbers: String, completionError: @escaping (Error)->()) {
         let isMath = typeRequest == TypeRequest.random
            
        networkManager.fetchNumber(inputedNumbers, type: NumberModel.self, mathRequest: isMath)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    completionError(error)
                case .finished: break
                }
            } receiveValue: { value in
                var numberDescript = value
                numberDescript.typeRequest = typeRequest
                self.oneNumberDescription = numberDescript
            }
            .store(in: &cancellable)
    }
    
    func fetchRangeNumber(_ inputedNumbers: String, completionError: @escaping (Error)->()) {
        networkManager.fetchNumber(inputedNumbers, type: RangeNumbers.self)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    completionError(error)
                case .finished: break
                }
            }, receiveValue: { value in
                self.rangeNumbersDescription = value
            })
            .store(in: &cancellable)
    }
}

