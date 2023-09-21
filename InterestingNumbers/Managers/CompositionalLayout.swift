//
//  CompositionalLayoutManager.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 20.09.2023.
//

import Foundation
import UIKit

enum CompositionalGroupAligment {
    case vertical
    case horizontal
}

struct CompositionalLayout {
    
    static func createItem(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, spacing: CGFloat) -> NSCollectionLayoutItem {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        return item
    }
    
    static func createGroupeItems(aligment: CompositionalGroupAligment, width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, items: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup {
        
        let groupSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        switch aligment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: items)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)
        }
    }
    
    static func createGroupeCount(aligment: CompositionalGroupAligment, width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, item: NSCollectionLayoutItem, count: Int) -> NSCollectionLayoutGroup {
        
        let groupSize = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        switch aligment {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: groupSize, repeatingSubitem: item, count: count)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: count)
        }
    }
}



