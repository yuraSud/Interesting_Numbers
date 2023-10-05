//
//  NumbersModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 19.09.2023.
//

import Foundation

struct NumberModel: Codable {
    
    var text: String? = nil
    var year: Int? = nil
    var number: Int? = nil
    var found: Bool? = nil
    var type: String? = nil
    
    var typeRequest: TypeRequest? = nil
}
