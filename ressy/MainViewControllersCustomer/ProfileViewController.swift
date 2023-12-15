//
//  ProfileViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 27.11.23.
//

import UIKit
import SwiftKeychainWrapper

class ProfileViewController: UIViewController{
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var othersView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var customerServiceButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var popupNotificationButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var languagesButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var joinedSinceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var gradient: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.editButton.layer.cornerRadius = 16
        
        settingsView.layer.borderColor = UIColor.white.cgColor
        settingsView.layer.borderWidth = 1
        settingsView.layer.cornerRadius = 10
        
        othersView.layer.borderColor = UIColor.white.cgColor
        othersView.layer.borderWidth = 1
        othersView.layer.cornerRadius = 10
        
        notificationView.layer.borderColor = UIColor.white.cgColor
        notificationView.layer.borderWidth = 1
        notificationView.layer.cornerRadius = 10
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
        
        addShadow(to: settingsView)
        addShadow(to: othersView)
        addShadow(to: notificationView)
        
        let tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIconSelected"))
        self.tabBarItem = tabBarItem
        
        fetchUserInfo { userInfo in
            if let userInfo = userInfo {
                DispatchQueue.main.async {
                    self.nameLabel.text = "\(userInfo.firstname) \(userInfo.lastname)"
                    self.joinedSinceLabel.text = "Joined since: \(userInfo.joinedSince)"
                }
            } else {
                self.showAlert(message: "Unable to fetch your information!")
            }
            
        }
        
        self.retrieveImageFromServer { (image) in
            if let image = image {
                DispatchQueue.main.async {
                    self.profileImage.image = image
                }
            } else {
                print("Failed to retrieve image")
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIconSelected"))
        self.tabBarItem = tabBarItem
    }
    
    
    @IBAction func editAction(_ sender: Any) {
        // Handle edit action if needed
    }
    
    @IBAction func languageAction(_ sender: Any) {
        // Handle language action if needed
    }
    
    @IBAction func locationAction(_ sender: Any) {
        // Handle location action if needed
    }
    
    @IBAction func notificationAction(_ sender: Any) {
        // Handle notification action if needed
    }
    
    @IBAction func aboutAction(_ sender: Any) {
        // Handle about action if needed
    }
    
    @IBAction func serviceAction(_ sender: Any) {
        // Handle service action if needed
    }
    
    @IBAction func inviteAction(_ sender: Any) {
        // Handle invite action if needed
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        KeychainWrapper.standard.removeObject(forKey: "jwtToken")
        if let entryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "entryVC") as? EntryViewController {
            let navigationController = UINavigationController(rootViewController: entryViewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
}
