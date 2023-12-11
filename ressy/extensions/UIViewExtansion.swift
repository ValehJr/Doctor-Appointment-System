//
//  UIViewExtansion.swift
//  ressy
//
//  Created by Valeh Ismayilov on 10.12.23.
//

import Foundation
import UIKit

public extension UIView {
    
    private static let kLayerNameGradientBorder = "GradientBorderLayer"
    
    func setGradientBorder(
        width: CGFloat,
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 1)
    ) {
        let existedBorder = gradientBorderLayer()
        let border = existedBorder ?? CAGradientLayer()
        border.frame = bounds
        border.colors = colors.map { return $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint
        border.name = UIView.kLayerNameGradientBorder
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width
        
        border.mask = mask
        
        let exists = existedBorder != nil
        if !exists {
            layer.addSublayer(border)
        }
    }
    
    func removeGradientBorder() {
        self.gradientBorderLayer()?.removeFromSuperlayer()
    }
    
    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter { return $0.name == UIView.kLayerNameGradientBorder }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }
}
