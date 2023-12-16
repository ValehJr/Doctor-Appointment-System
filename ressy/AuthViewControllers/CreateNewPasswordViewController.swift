//
//  CreateNewPasswordViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 26.11.23.
//

import UIKit

class CreateNewPasswordViewController: UIViewController {
    
    @IBOutlet weak var createLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmPasswordHideButton: UIButton!
    @IBOutlet weak var passwordHideButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var confirmPasswordField: PaddedTextField!
    @IBOutlet weak var passwordField: PaddedTextField!
    
    var email:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordField.layer.cornerRadius = 15
        self.confirmPasswordField.layer.cornerRadius = 15
        self.submitButton.layer.cornerRadius = 26
        
        passwordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        confirmPasswordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        
        submitButton.alpha = 0.75
        
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func passwordHIdeAction(_ sender: Any) {
        togglePasswordVisibility(for: passwordField, with: passwordHideButton)
    }
    
    @IBAction func confirmPasswordHideAction(_ sender: Any) {
        togglePasswordVisibility(for: confirmPasswordField, with: confirmPasswordHideButton)
    }
    
    @IBAction func confirmAction(_ sender: Any) {
        guard let password = passwordField.text, let confirmPassword = confirmPasswordField.text, let email = self.email else {
            print("Failed: Missing required fields")
            return
        }
        
        if password.count < 8 {
            showAlert(message: "Password must be at least 8 characters!")
            return
        }
        
        if password != confirmPassword {
            showAlert(message: "Password and Confirm password must be equal!")
            return
        }
        
        guard let encodedURL = URL(string:GlobalConstants.apiUrl + "/auth/forgot?email=\(email)&otpValid=OTP_CODE_VALID&password=\(password)")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            print("Failed to create URL")
            return
        }
        
        let parameters: [String: Any] = [
            "email": email,
            "password": password,
            "otpValid":"OTP_CODE_VALID"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            print("Failed to create JSON data")
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Sending request to URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                print("Received data: \(data)")
                
                guard !data.isEmpty else {
                    print("Error: Empty data received")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("Response JSON: \(json)")
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP status code: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        if let loginVC = self.navigationController?.viewControllers.first(where: { $0 is LoginViewController }) {
                            self.navigationController?.popToViewController(loginVC, animated: true)
                            self.showSuccess(message: "Password was updated successfully.")
                        }
                    }
                } else {
                    print("Unsuccessful HTTP status code: \(httpResponse.statusCode)")
                }
            }
        }
        print("Starting data task")
        task.resume()
    }
    
}
