//
//  SelectHourCollectionViewCell.swift
//  ressy
//
//  Created by Valeh Ismayilov on 10.12.23.
//

import UIKit

class SelectHourCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    let firstGradColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
    let secondGradColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
    func addGradientToView(_ view: UIView, firstColor: UIColor, secondColor: UIColor) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        gradientLayer.frame = view.bounds
        
        view.clipsToBounds = true
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
