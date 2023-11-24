//
//  ForgetPasswordViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 24.11.23.
//

import UIKit

class ForgetPasswordViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailField: PaddedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.layer.cornerRadius = 15
        self.sendButton.layer.cornerRadius = 26
        
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
        guard let email = emailField.text else {
            print ("Failed")
            return
        }
        
        let url = URL(string: "http://ec2-34-241-107-14.eu-west-1.compute.amazonaws.com:8080/auth/forgot?email=\(email)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else {
                
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
                    self.navigationController?.pushViewController(loginVC, animated: true)
                    print("Password reset email sent successfully")
                }
            }
        }.resume()
    }
}

