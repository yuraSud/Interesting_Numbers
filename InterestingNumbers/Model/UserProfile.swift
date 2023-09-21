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
    var countRequest: Int?
    var imageId: String?
    
    var firstLetter: String {
        return name.first?.uppercased() ?? "?"
    }
}

//^[123]{0,4}[\.]{0,2}\d{0,4}$

//^([0-9]{0,2})([.][0-9]{0,2})?$
