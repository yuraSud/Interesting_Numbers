//
//  AddProductViewModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 19.09.2023.
//

import Foundation
import Combine
import UIKit

class AddProductViewModel {
    
    @Published var name: String = ""
    @Published var cost: String = ""
    @Published var image: UIImage?
    var error: String? {
        didSet {
            guard let error else {return}
            postErrorMassedge(textError: error)
        }
    }
    
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
    
    func addToServer(completion: @escaping (Bool)->()) {
        guard let imageData = image?.jpegData(compressionQuality: 0.2) else {
            error = "Do not transform Jpeg to Data"
            return
        }
        let product = ProductModel(nameProduct: name, cost: cost, id: UUID().uuidString)
        DatabaseService.shared.addProduct(product: product, image: imageData) { result in
            switch result {
            case .success(let sizeInfo):
                self.error = sizeInfo
                completion(true)
            case .failure(let err):
                self.error = err.localizedDescription
            }
        }
    }
    
    private func postErrorMassedge(textError: String) {
        NotificationCenter.default.post(name: Notification.errorPost, object: nil, userInfo: ["error": textError])
    }
}
