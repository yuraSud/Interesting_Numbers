//
//  SectionsCollection.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//

import Foundation

enum Section: Int, CaseIterable {
    case product
   // case recently
   // case favorite
    
    func columnCount(for width: CGFloat) -> Int {
        let wideMode = width > 800
        switch self {
        case .product:
            return wideMode ? 6 : 3
      //  case .recently:
    //        return wideMode ? 2 : 1
//            case .favorite:
//                return wideMode ? 2 : 1
        }
    }
}
