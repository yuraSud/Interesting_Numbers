//
//  ValidateRequestManager.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 24.09.2023.
//

import Foundation

struct ValidateManager {
    
    func isContainsOnlyDigits(text: String) -> Bool {
        let regularExpression = "^([0-9]{0,})$"
        return NSPredicate(format: "SELF MATCHES %@", regularExpression).evaluate(with: text)
    }
    
    func isValidRange(_ text: String) -> Bool {
        let regularExpression = "^[0-9]{1,4}.{2}[0-9]{1,4}$"
        let isCorrectText = NSPredicate(format: "SELF MATCHES %@", regularExpression).evaluate(with: text)
        
        let range = text.components(separatedBy: "..").compactMap { Int($0) }
        let isCorrectRange = range.count > 1 && range[1] > range[0]
       
        return isCorrectText && isCorrectRange
    }
    
    func isValidDate(_ text: String) -> Bool {
        let regularExpression = "^([0-9]{0,2})/?[0-9]{0,2}?$"
        let isCorrectText = NSPredicate(format: "SELF MATCHES %@", regularExpression).evaluate(with: text)
        
        let date = text.components(separatedBy: "/").compactMap { Int($0) }
        let isCorrectDate = date.count > 1 && date[0] <= 12 && date[1] <= 31
        
        return isCorrectText && isCorrectDate
    }
}
