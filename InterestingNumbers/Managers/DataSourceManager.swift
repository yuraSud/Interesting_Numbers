//
//  DataSourceManager.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 22.09.2023.
//

import Foundation

struct DataSourceManager {
    var headerArray: [HeaderSectionModel] = []
   
    
    mutating func createDataSourceHeaderAndSections(products: [ProductModel], headers: [HeaderSectionModel], completion: (Error)->Void) -> [[ProductModel]] {
        print("Begin create DataSource")
        guard !products.isEmpty && !headers.isEmpty else {
            completion(ModelsError.productHeaderIsEmpty)
            return [] }
        
        var favouriteArrayProducts: [ProductModel] = []
        
        products.forEach{ value in
            if value.isFavourite == true {
                favouriteArrayProducts.append(value)
            }
        }
        
        self.headerArray = headers.sorted(by: { $0.number < $1.number })

        var sections = headerArray.map { header in
            return products
                .filter { $0.category == header.title }
                .sorted { $0.cost < $1.cost }
        }
        
        guard !sections.isEmpty else {
            completion(ModelsError.sectionsArrayIsEmpty)
            return [] }
        
        sections.removeFirst()
        sections.insert(favouriteArrayProducts, at: 0)
        return sections
    }
}

