//
//  StoreCollectionViewModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//
import Combine
import Foundation

class StoreCollectionViewModel {
    
    @Published var products: [ProductModel] = []
    
    init() {
        getProducts()
    }
    
    func numberOfSections() -> Int {
        Section.allCases.count
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        guard let sectionKind = Section(rawValue: section) else {return 0}
        switch sectionKind {
        case .product:
            return products.count
        }
    }
    
    func getProducts() {
        Task {
            do {
                products = try await DatabaseService.shared.getAllProducts()
            } catch let err {
                print(err)
            }
        }
    }
    
}
