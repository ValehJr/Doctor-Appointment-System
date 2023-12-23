//
//  HomeViewControllerDoctor.swift
//  ressy
//
//  Created by Valeh Ismayilov on 15.12.23.
//

import UIKit
import SwiftKeychainWrapper

class ProfileViewControllerDoctor: UIViewController {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var otherView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var joinedSinceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var firstName:String?
    var lastName:String?
    
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
        configureRoundedBorders(for: otherView)
        configureRoundedBorders(for: notificationView)
        
        configureRoundedProfileImage()
        
        addShadow(to: settingsView)
        addShadow(to: otherView)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        let tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIconSelected"))
        self.tabBarItem = tabBarItem
        fetchAndDisplayUserInfo()
    }
    
    @IBAction func editAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editVC = storyboard.instantiateViewController(withIdentifier: "editVC") as! EditPatientViewController
        editVC.initialFirstName = firstName
        editVC.initialLastName = lastName
        navigationController?.pushViewController(editVC, animated: true)
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
