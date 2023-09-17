//
//  UIView+Extension.swift
//  InterestingNumbers
//
//  Created by Olga Sabadina on 09.09.2023.
//

import UIKit

extension UIView {
    func setBorderLayer(backgroundColor: UIColor, borderColor: UIColor, borderWidth: CGFloat, cornerRadius: CGFloat, tintColor: UIColor?) {
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        clipsToBounds = true
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
    }
}
