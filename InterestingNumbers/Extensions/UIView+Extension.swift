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
    
    func setShadowWithCornerRadius(cornerRadius: CGFloat, shadowColor: UIColor, shadowOffset: CGSize, shadowOpacity: Float = 1, shadowRadius: CGFloat = 15) {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.shadowRadius = shadowRadius
    }
    
    func setShadow(color: UIColor, offsetWidh: Int, offseHeight: Int, opacity: Float, radius: CGFloat, masksToBounds: Bool, cornerRadius: CGFloat ) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: offsetWidh, height: offseHeight)
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.masksToBounds = masksToBounds
        layer.cornerRadius = cornerRadius
    }
}
