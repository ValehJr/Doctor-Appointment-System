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
    
    var firstName:String?
    var lastName:String?
    
    var gradient: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureTabBarItem()
        fetchAndDisplayUserInfo()
        fetchAndDisplayProfileImage()
    }

    func configureUI() {
        editButton.layer.cornerRadius = 16
        
        configureRoundedBorders(for: settingsView)
        configureRoundedBorders(for: othersView)
        configureRoundedBorders(for: notificationView)
        
        configureRoundedProfileImage()
        
        addShadow(to: settingsView)
        addShadow(to: othersView)
        addShadow(to: notificationView)
    }

    func configureRoundedBorders(for view: UIView) {
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
    }

    func configureRoundedProfileImage() {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
    }

    func configureTabBarItem() {
        let tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIconSelected"))
        self.tabBarItem = tabBarItem
    }

    func fetchAndDisplayUserInfo() {
        fetchUserInfo { userInfo in
            if let userInfo = userInfo {
                DispatchQueue.main.async {
                    self.nameLabel.text = "\(userInfo.firstname) \(userInfo.lastname)"
                    self.joinedSinceLabel.text = "Joined since: \(userInfo.joinedSince)"
                    self.firstName = userInfo.firstname
                    self.lastName = userInfo.lastname
                }
            } else {
                self.showAlert(message: "Unable to fetch your information!")
            }
        }
    }

    func fetchAndDisplayProfileImage() {
        retrieveImageFromServer { (image) in
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
        fetchAndDisplayUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @IBAction func editAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editVC = storyboard.instantiateViewController(withIdentifier: "editVC") as! EditPatientViewController
        editVC.initialFirstName = firstName
        editVC.initialLastName = lastName
        navigationController?.pushViewController(editVC, animated: true)
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
