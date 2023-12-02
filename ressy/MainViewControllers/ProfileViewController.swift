//
//  ProfileViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 27.11.23.
//

import UIKit
import SwiftKeychainWrapper

class ProfileViewController: UIViewController {
    
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
        
        
        addShadow(to: settingsView)
        addShadow(to: othersView)
        addShadow(to: notificationView)
        
        
        
        let tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIconSelected"))
        self.tabBarItem = tabBarItem
        
        
        fetchUserInfo()
        getImageFromServerAndDisplayInImageView(imageView: profileImage)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profileIcon"), selectedImage: UIImage(named: "profileIconSelected"))
        self.tabBarItem = tabBarItem
    }
    
    private func fetchUserInfo() {
        guard let url = createURL() else {
            print("Invalid URL")
            return
        }
        
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }
        
        var request = URLRequest(url: url)
        let token = jwtToken
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            } else if let data = data {
                print("DAta:\(data)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Received data:\(responseString)")
                }
                guard !data.isEmpty else {
                    print("Error: Empty data received")
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let dataDict = json["data"] as? [String: Any] {
                        let firstname = dataDict["firstname"] as? String ?? ""
                        let lastname = dataDict["lastname"] as? String ?? ""
                        let joinDate = dataDict["joinDate"] as? String ?? ""
                        
                        let userInfo = UserInfo(firstname: firstname, lastname: lastname, joinedSince: joinDate)
                        
                        DispatchQueue.main.async {
                            self.updateUI(with: userInfo)
                        }
                    } else {
                        print("Failed to parse JSON")
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
    
    func updateUI(with userInfo: UserInfo) {
        DispatchQueue.main.async {
            self.nameLabel.text = "\(userInfo.firstname) \(userInfo.lastname)"
            self.joinedSinceLabel.text = "Joined since: \(userInfo.joinedSince)"
            
        }
    }
    
    func createURL() -> URL? {
        guard let encodedURL = URL(string: "http://ec2-54-155-120-5.eu-west-1.compute.amazonaws.com:8080/user")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            return nil
        }
        return url
    }
    
    func fetchProfileImage() {
        let apiUrl = "http://ressy-user-service-708424409.eu-west-1.elb.amazonaws.com/user/photo"
        
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }
        
        let token = jwtToken
        
        guard let url = URL(string: apiUrl) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                if let base64String = String(data: data, encoding: .utf8) {
                    DispatchQueue.global().async {
                        if let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
                            print(imageData)
                            if let image = UIImage(data: imageData) {
                                DispatchQueue.main.async {
                                    self.profileImage.image = image
                                }
                            } else {
                                print("Failed to convert data to image")
                            }
                        } else {
                            print("Failed to decode base64 string to data")
                        }
                    }
                } else {
                    print("Failed to convert data to base64 string")
                }
            }
        }
        task.resume()
    }
    
    
    @IBAction func imageButtonAction(_ sender: Any) {
        showImagePicker()
    }
    
    @IBAction func editAction(_ sender: Any) {
        
    }
    
    @IBAction func languageAction(_ sender: Any) {
        
    }
    
    @IBAction func locationAction(_ sender: Any) {
        
    }
    
    @IBAction func notificationAction(_ sender: Any){
        
    }
    
    @IBAction func aboutAction(_ sender: Any) {
        
    }
    
    @IBAction func serviceAction(_ sender: Any) {
        
    }
    
    @IBAction func inviteAction(_ sender: Any) {
        
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
