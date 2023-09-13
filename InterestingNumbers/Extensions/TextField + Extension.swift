//
//  TextField + Extension.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 11.09.2023.
//

import UIKit

extension UITextField {

    func setCustomPlaceholder(placeholderLabel: UILabel, frame: CGRect) {
        self.addSubview(placeholderLabel)
        placeholderLabel.frame = frame
        placeholderLabel.textColor = .lightGray
        placeholderLabel.font = .systemFont(ofSize: 15)
        
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.clearButtonMode = .whileEditing
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        self.leftView = leftView
        self.leftViewMode = .always
    }
}
