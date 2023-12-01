//
//  MainTabViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 26.11.23.
//

import UIKit

class MainTabViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tintColor = UIColor(red: 146/255, green: 172/255, blue: 253/255, alpha: 1)
        
        tabBar.tintColor = tintColor
    }
    
}
