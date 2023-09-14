//
//  Profile.swift
//  Interesting_Numbers
//
//  Created by Olga Sabadina on 13.09.2023.
//

import Foundation

enum ProfileFields: String {
    case name
    case email
    case age
    case gender
}

enum Gender: String, Codable {
    case male
    case female
}
