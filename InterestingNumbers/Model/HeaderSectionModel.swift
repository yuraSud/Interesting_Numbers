//
//  HeaderSectionModel.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 22.09.2023.
//

import Foundation
import FirebaseFirestore

struct HeaderSectionModel: Codable {
    
    var number: Int
    var title: String
    var imageId: String
    
    init(number: Int, title: String, imageId: String) {
        self.number = number
        self.title = title
        self.imageId = imageId
    }
    
    init?(qSnapShot: QueryDocumentSnapshot) {
        let data = qSnapShot.data()
        let number = data["number"] as? Int
        let title = data["title"] as? String
        let imageId = data["imageId"] as? String
        
        self.number = number ?? 100
        self.title = title ?? "Nothin"
        self.imageId = imageId ?? "Nothin"
    }
}
