//
//  EditPatientViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 23.12.23.
//

import UIKit
import SwiftKeychainWrapper

class EditPatientViewController: UIViewController {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var surnameField: PaddedTextField!
    @IBOutlet weak var nameField: PaddedTextField!
    
    var initialFirstName: String?
        var initialLastName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameField.layer.cornerRadius = 15
        surnameField.layer.cornerRadius = 15
        submitButton.layer.cornerRadius = 26
        
        let textColor = UIColor(red: 154/255.0, green: 162/255.0, blue: 178/255.0, alpha: 1)
        nameField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        surnameField.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        
        nameField.text = initialFirstName
        surnameField.text = initialLastName
        
        hideKeyboardWhenTappedAround()
        
        self.title = "Details Edit"
        let titleFont = UIFont(name: "Poppins-SemiBold", size: 18)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: titleFont!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        changeNavBar(navigationBar:  self.navigationController!.navigationBar, to: .white,titleColor: .black)
        customizeBackButton()
        
        surnameField.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        nameField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSAttributedString.Key.foregroundColor: textColor])
    }
    
    func changeNavBar(navigationBar: UINavigationBar, to color: UIColor, titleColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        guard let url = URL(string: "http://ressy-user-service-708424409.eu-west-1.elb.amazonaws.com/user/edit") else {
            print("Invalid URL")
            return
        }
        
        guard let patName = nameField.text, let patSurname = surnameField.text else {
            return
        }
        
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }
        
        let patientInformation: [String: Any] = [
            "firstname": patName,
            "lastname": patSurname
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: patientInformation)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let data = data {
                    let responseString = String(data: data, encoding: .utf8)
                    print("Response: \(responseString ?? "")")
                    DispatchQueue.main.async {
                        if let navigationController = self.navigationController {
                            navigationController.popToRootViewController(animated: true)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            
            task.resume()
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
        }
    }
    
}
