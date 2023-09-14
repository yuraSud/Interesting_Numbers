//
//  UserProfile.swift
//  Interesting_Numbers
//
//  Created by Olga Sabadina on 13.09.2023.
//

import Foundation


struct UserProfile: Codable {
    
    var name: String
    var email: String
    var age: Int?
    var gender: Gender?
    
    var firstLetter: String {
        return name.first?.uppercased() ?? "?"
    }
}
