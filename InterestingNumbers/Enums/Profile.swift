//
//  Profile.swift
//  Interesting_Numbers
//
//  Created by Olga Sabadina on 13.09.2023.
//

import Foundation

enum ProfileEnum: String {
    case name
    case email
    case age
    case sex
}

enum Sex: String, Codable {
    case male
    case female
}
