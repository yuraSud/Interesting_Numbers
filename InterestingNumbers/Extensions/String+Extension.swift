//
//  String+Extension.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 17.09.2023.
//

import Foundation

extension String {
    var returnFirstLetterUppercase: String {
        return prefix(1).uppercased() + self.dropFirst()
    }
}
