//
//  StoreErrors.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 28.09.2023.
//

import Foundation

enum StoreErrors: String, Error {
    case productHeaderIsEmpty = "Products array or Headers array is empty!"
    case sectionsArrayIsEmpty = "Data Source array is empty!"
}
