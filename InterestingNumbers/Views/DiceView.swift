//
//  DiceView.swift
//  Interesting_Numbers
//
//  Created by Yura Sabadin on 24.09.2023.
//

import UIKit

class BezierPathView: UIView {
    
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
            
            // Call a function to draw the dice with UIBezierPath
        }
    
    private func setupView() {
            // Ensure that the background color respects the view's bounds
            backgroundColor = .yellow
            clipsToBounds = true
            layer.cornerRadius = 20.0
        }
    
    func rotate() {
        let rotationAngle = CGFloat.pi / 4.0 // 45 degrees in radians
               transform = CGAffineTransform(rotationAngle: rotationAngle)
        setNeedsDisplay()
    }
        
        func drawDice() {
            // Clear the current drawing
//            UIColor.white.setFill()
//            UIRectFill(bounds)
            
            // Set the stroke color
            UIColor.gray.setStroke()
            
            // Create a UIBezierPath for the dice outline
            let dicePath = UIBezierPath(roundedRect: bounds, cornerRadius: 20.0)
            dicePath.lineWidth = 9.0
            
            
            // Draw the dice outline
            dicePath.stroke()
            
            // Draw the dots (pips) on the dice
            drawPips()
        }
        
        func drawPips() {
            // Set the dot color
            UIColor.black.setFill()
            
            // Define the center points for each of the six dots (pips)
            let dotSize: CGFloat = 9.0
            let centerX = bounds.midX
            let centerY = bounds.midY
            let offset = bounds.width / 4.0
            
            let topLeft = CGPoint(x: centerX - offset, y: centerY - offset)
            let topRight = CGPoint(x: centerX + offset, y: centerY - offset)
            let middleLeft = CGPoint(x: centerX - offset, y: centerY)
            let middleRight = CGPoint(x: centerX + offset, y: centerY)
            let bottomLeft = CGPoint(x: centerX - offset, y: centerY + offset)
            let bottomRight = CGPoint(x: centerX + offset, y: centerY + offset)
            
            // Create a function to draw a single dot (pip)
            func drawDot(at point: CGPoint) {
                let dotRect = CGRect(x: point.x - dotSize / 2, y: point.y - dotSize / 2, width: dotSize, height: dotSize)
                let dotPath = UIBezierPath(ovalIn: dotRect)
                dotPath.fill()
            }
            
            // Draw the pips
            drawDot(at: topLeft)
            drawDot(at: topRight)
            drawDot(at: middleLeft)
            drawDot(at: middleRight)
            drawDot(at: bottomLeft)
            drawDot(at: bottomRight)
        }
    }

