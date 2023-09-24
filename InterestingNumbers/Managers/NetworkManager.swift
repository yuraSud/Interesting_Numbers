//
//  NetworkManager.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 24.09.2023.
//

import Foundation
import Combine

class NetworkManager {
    
    private let baseUrl = "http://numbersapi.com/"
    private let endForJson = "?json"
    private var cancellable: Set<AnyCancellable> = []
    
    func fetchNumber<T:Codable>(typeRequest: TypeRequest, _ inputedNumbers: String, type: T.Type) -> AnyPublisher<T,Error> {
         guard let self,
                  let url = URL(string: self.baseUrl + inputedNumbers + self.endForJson) else {
                return promise(.failure(AuthorizeError.badUrl))
            }
            
            URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .receive(on: DispatchQueue.main)
                .decode(type: T.self, decoder: JSONDecoder())
                .sink { completion in
                    promise(.failure(completion as! Error))
                } receiveValue: { value in
                    var numberModel = value
                    promise(.success(numberModel))
                }
                .store(in: &cancellable)
        }
    }
}
