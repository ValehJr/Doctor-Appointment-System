//
//  SearchField.swift
//  ressy
//
//  Created by Valeh Ismayilov on 15.12.23.
//

import Foundation
import UIKit

class SearchField: UITextField {
    
    let padding = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
