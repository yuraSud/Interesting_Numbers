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
    var uid: String = ""
    var countRequest: Int = 0
    var imageId: String?
    var isUserAdmin = false
    
    var firstLetter: String {
        return name.first?.uppercased() ?? "?"
    }
}
