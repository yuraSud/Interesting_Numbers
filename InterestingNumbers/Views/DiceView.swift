//
//  DiceView.swift
//  InterestingNumbers
//
//  Created by Yura Sabadin on 26.09.2023.
//

import UIKit

final class DiceView: UIView {
    
    enum DicePips: Int {
       case one, two, three, four, five, six
    }
    
    var dicePips: DicePips = .one
    private let dotSize: CGFloat = 15.0
    private var topLeft = CGPoint()
    private var topRight = CGPoint()
    private var middle = CGPoint()
    private var bottomLeft = CGPoint()
    private var bottomRight = CGPoint()
    private var leftMiddle = CGPoint()
    private var rightMiddle = CGPoint()
    
    private var pipsArray: [CGPoint] {
        switch dicePips {
        case .one:
            return [middle]
        case .two:
            return [topLeft, bottomRight]
        case .three:
            return [topLeft, middle, bottomRight]
        case .four:
            return [topLeft, topRight, bottomRight, bottomLeft]
        case .five:
            return [topLeft, topRight, middle, bottomRight, bottomLeft]
        case .six:
            return [topLeft, topRight, bottomRight, bottomLeft, leftMiddle, rightMiddle]
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawDice()
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        clipsToBounds = true
        layer.cornerRadius = 20.0
    }
    
    func rotateDice() {
        let diceOne = CGFloat.random(in: -4...4)
        let rotationAngle = CGFloat.pi / diceOne
        UIView.animate(withDuration: 1, delay: 0.2, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: .curveEaseInOut) {
            self.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
    
    func drawDice() {
        UIColor.customColor.withAlphaComponent(0.1).setStroke()
        let dicePath = UIBezierPath(roundedRect: bounds, cornerRadius: 20.0)
        dicePath.lineWidth = 15.0
        dicePath.stroke()
        let diceOne = Int.random(in: 1...6)
        self.dicePips = DicePips(rawValue: diceOne) ?? .one
        drawPips()
        rotateDice()
    }
    
    func drawPips() {
        UIColor.customColor.withAlphaComponent(0.1).setFill()
        let centerX = bounds.midX
        let centerY = bounds.midY
        let offset = bounds.width / 5.0
        
        topLeft = CGPoint(x: centerX - offset, y: centerY - offset)
        topRight = CGPoint(x: centerX + offset, y: centerY - offset)
        middle = CGPoint(x: centerX, y: centerY)
        bottomLeft = CGPoint(x: centerX - offset, y: centerY + offset)
        bottomRight = CGPoint(x: centerX + offset, y: centerY + offset)
        leftMiddle = CGPoint(x: centerX - offset, y: centerY)
        rightMiddle = CGPoint(x: centerX + offset, y: centerY)
        
        pipsArray.forEach { point in
            drawDot(at: point)
        }
    }
    
    func drawDot(at point: CGPoint) {
        UIColor.customColor.withAlphaComponent(0.1).setFill()
        let dotRect = CGRect(x: point.x - dotSize / 2, y: point.y - dotSize / 2, width: dotSize, height: dotSize)
        let dotPath = UIBezierPath(ovalIn: dotRect)
        dotPath.fill()
    }
}
