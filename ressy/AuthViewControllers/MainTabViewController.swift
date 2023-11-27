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
        
        if let tabBarItem3 = self.tabBarController?.tabBar.items?[2] {
            tabBarItem3.title = "Profile"
            tabBarItem3.image = UIImage(named: "profileIcon")
            tabBarItem3.selectedImage = UIImage(named: "profileIconSelected")
        }
    }
    
}
