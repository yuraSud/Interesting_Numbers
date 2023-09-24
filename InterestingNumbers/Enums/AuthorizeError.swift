//
//  AuthorizeError.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 14.09.2023.
//

import Foundation

enum AuthorizeError: String, Error {
    case uid = "Your UID is empty, Can't receive..."
    case errorParceProfile = "Can't parce data to Profile struct"
    case docNotExists = "Sorry. \nThis document not exists"
    case sendDataFailed = "Sorry, can't send data profile to server FireStore"
    case noFoundID = "NO client ID found in FireBase configuration"
    case notRootVC = "There is no root view controller "
    case errorToken = "ID token missing"
    case cancelAppleAuth = "Canceled Apple sign in authentication"
    case userNotFound = "Sorry user not found"
    case badUrl = "Bad url"
}

enum ModelsError: String, Error {
    case productHeaderIsEmpty = "Products array or Headers array is empty!"
    case sectionsArrayIsEmpty = "Data Source array is empty!"
}
