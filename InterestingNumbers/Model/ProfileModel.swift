//
//  ProfileModel.swift
//  Interesting_Numbers
//
//  Created by Olga Sabadina on 13.09.2023.
//

import Foundation


struct Profile: Codable {
    
    var name: String?
    var email: String?
    var age: Int?
    var sex: Sex?
}
