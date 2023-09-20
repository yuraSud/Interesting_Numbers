//
//  AddProductViewModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 19.09.2023.
//

import Foundation
import Combine

class AddProductViewModel {
    
    let authManager = AuthorizationService.shared
    
    @Published var name: String = ""
    @Published var cost: String = ""
    @Published var image: Data?
    
    var cancellable = Set<AnyCancellable>()
    
    var addIsEnable: AnyPublisher<Bool,Never> {
        return Publishers.CombineLatest3($name, $cost, $image)
            .map{name, cost, image in
                let nameIsInput = !name.isEmpty
                let costIsInput = !cost.isEmpty
                let imageNotNil = image != nil
                return nameIsInput && costIsInput && imageNotNil
            }
            .eraseToAnyPublisher()
    }
    
    init() {
        
    }
    
    func addToServer() {
        print("Add to server")
    }
    
}
