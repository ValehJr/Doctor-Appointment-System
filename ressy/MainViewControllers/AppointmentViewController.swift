//
//  AppointmentViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 27.11.23.
//

import UIKit

class AppointmentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let tabBarItem = UITabBarItem(title: "Appointment", image: UIImage(named: "calendarIcon"), selectedImage: UIImage(named: "calendarIcon"))
        self.tabBarItem = tabBarItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tabBarItem = UITabBarItem(title: "Appointment", image: UIImage(named: "calendarIcon"), selectedImage: UIImage(named: "calendarIcon"))
        self.tabBarItem = tabBarItem
    }

}
