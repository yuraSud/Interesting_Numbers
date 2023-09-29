//
//  NetworkManager.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 24.09.2023.
//

import Foundation
import Combine

final class NetworkManager {
    
    private let baseUrl = "http://numbersapi.com/"
    private let endForJson = "?json"
    private let math = "/math"
    
    func fetchNumber<T:Codable>(_ numberRequest: String, type: T.Type, mathRequest: Bool = false) -> AnyPublisher<T,Error> {
        
        let urlMathString = baseUrl + numberRequest + math + endForJson
        let urlString = baseUrl + numberRequest + endForJson
        
        let urlRequestString = mathRequest ? urlMathString : urlString
        
        guard let url = URL(string: urlRequestString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
            }
            return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .mapError { error in
                    return error
                }
                .eraseToAnyPublisher()
        }
    }
