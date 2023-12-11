//
//  CalendarDayCVC.swift
//  CustomDatePicker
//
//  Created by Recep Oğuzhan Şenoğlu on 22.09.2023.
//

import UIKit

class CalendarDayCVC: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak private var backgroundUIView: UIView!
    @IBOutlet weak private var dayNumberLabel: UILabel!
    
    // MARK: - Functions
    
    func setup(_ calendarDate: CalendarDate, selected: Bool) {
        let today = calendarDate.date.isEqual(Date.now)
        let available = calendarDate.available && calendarDate.calendarMonth == .Current
        backgroundUIView.layer.cornerRadius = backgroundUIView.frame.size.width / 2
        backgroundUIView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        backgroundUIView.layer.masksToBounds = true
        let firstColor = UIColor(red: 160/255.0, green: 187/255.0, blue: 249/255.0, alpha: 1.0)
        backgroundUIView.backgroundColor = selected ? today ? firstColor : firstColor : UIColor.clear
        dayNumberLabel.text = String(calendarDate.date.day())
        let textColor = selected ? today ? UIColor.white : UIColor.white : today ? UIColor.black : available ? UIColor.black : UIColor.lightGray
        dayNumberLabel.textColor = textColor
        dayNumberLabel.font = selected ? UIFont(name: "Poppins-SemiBold", size: 12) : today ? UIFont(name: "Poppins-SemiBold", size: 12) : UIFont(name: "Poppins-Regular", size: 12)
    }

}
