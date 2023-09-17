//
//  ViewController + Alert.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 14.09.2023.
//

import UIKit

extension UIViewController {
    
    func presentAlert(with title: String, message: String?, buttonTitles options: String...,styleActionArray: [UIAlertAction.Style?], alertStyle: UIAlertController.Style, completion: ((Int) -> Void)?) {
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
            
            for (index, option) in options.enumerated() {
                alertController.addAction(UIAlertAction.init(title: option, style: styleActionArray[index] ?? .default, handler: { (action) in
                    completion?(index)
                }))
            }
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
