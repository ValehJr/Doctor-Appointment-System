//
//  MainViewControllerDoctor.swift
//  ressy
//
//  Created by Valeh Ismayilov on 15.12.23.
//

import UIKit

class MainViewControllerDoctor: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var upcommingCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.layer.cornerRadius = 24
        
        let tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeIcon"), selectedImage: UIImage(named: "homeIconSelected"))
        self.tabBarItem = tabBarItem
        
        fetchUserInfo { userInfo in
            if let userInfo = userInfo {
                DispatchQueue.main.async {
                    self.nameLabel.text = "\(userInfo.firstname) \(userInfo.lastname)"
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
        let tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeIcon"), selectedImage: UIImage(named: "homeIconSelected"))
        self.tabBarItem = tabBarItem
    }
    
    @IBAction func seeAllAction(_ sender: Any) {
        
    }
    
}
