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
    private let math = "/math"
    private var cancellable: Set<AnyCancellable> = []
    
    func fetchNumber<T:Codable>(_ numberRequest: String, type: T.Type, mathRequest: Bool = false) -> AnyPublisher<T,Never> {
        
        let urlMathString = baseUrl + numberRequest + math + endForJson
        let urlString = baseUrl + numberRequest + endForJson
        
        let urlrequestString = mathRequest ? urlMathString : urlString
        
        guard let url = URL(string: urlrequestString) else {
            return Just(T.self as! T)
                .eraseToAnyPublisher()
            }
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .catch{error in Just(T.self as! T)}
                .eraseToAnyPublisher()
        }
    }
