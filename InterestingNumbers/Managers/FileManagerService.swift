//
//  FileManagerService.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 22.09.2023.
//

import Foundation

class FileManagerService {
    
    static let instance = FileManagerService()
    let fileManager = FileManager.default
    let nameDirectory = "BooksHtml"
    
    func getPath(name: String) -> URL? {
        guard let path = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(nameDirectory)
            .appendingPathComponent(name) else {
            print("Error getting path")
            return nil
        }
        print(path)
        return path
    }
}
