//
//  DiceView.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 24.09.2023.
//

import UIKit

class BezierPathView: UIView {
    
    var bezierPath = UIBezierPath()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    override func draw(_ rect: CGRect) {
       
        var path = bezierPath
        path = UIBezierPath(ovalIn: CGRect(x: self.bounds.width / 2, y: self.bounds.height / 2, width: 30, height: 30))
        UIColor.red.setStroke()
        UIColor.yellow.setFill()
        path.lineWidth = 5
        path.stroke()
        path.fill()

        var path1 = bezierPath
        path1 = UIBezierPath(ovalIn: CGRect(x: 100, y: 100, width: 30, height: 30))
        UIColor.red.setStroke()
        UIColor.blue.setFill()
        path1.lineWidth = 5
        path1.stroke()
        path1.fill()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setView() {
        backgroundColor = .secondarySystemBackground
    }
    
}
