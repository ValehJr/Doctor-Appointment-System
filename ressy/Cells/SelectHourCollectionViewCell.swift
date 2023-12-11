//
//  SelectHourCollectionViewCell.swift
//  ressy
//
//  Created by Valeh Ismayilov on 10.12.23.
//

import UIKit

class SelectHourCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var timeButton: UIButton!
    @objc func buttonClicked() {
        // Change the background color to red
        timeButton.backgroundColor = UIColor.red
    }
}
