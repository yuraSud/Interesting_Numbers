//
//  RequestNumberViewModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 24.09.2023.
//

import UIKit
import Combine

class RequestNumberViewModel {
    
    static let shared = RequestNumberViewModel()
    private init() {}
    let networkManager = NetworkManager()
    
    private let baseUrl = "http://numbersapi.com/"
    private let endForJson = "?json"
    private var cancellable: Set<AnyCancellable> = []
    
    @Published var oneNumberDescription: Future<ChooseNumbers,Error>?
    @Published var rangeNumbersDescription: [String:String] = [:]
    
    func fetchNumber(typeRequest: TypeRequest, _ inputedNumbers: String) {
        var e = networkManager.fetchNumber(typeRequest: typeRequest, inputedNumbers, type: ChooseNumbers.self)
    
    }
    
    func fetchRangeNumber(typeRequest: TypeRequest, _ inputedNumbers: String) {
        guard let url = URL(string: baseUrl + inputedNumbers + endForJson) else { return }
        URLSession.shared.dataTaskPublisher(for: url)
                    .map { $0.data}
                    .decode(type: RangeNumbers.self, decoder: JSONDecoder())
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: RangeNumbers())
                    .eraseToAnyPublisher()
                    .sink(receiveValue: { value in
                        self.rangeNumbersDescription = value
                        
                    }).store(in: &cancellable)
    }
}

