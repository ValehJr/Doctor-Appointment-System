//
//  RegisterViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 19.11.23.
//

import UIKit

class RegisterCustomerViewController: UIViewController {
    
    @IBOutlet weak var confirmPasswordHideButton: UIButton!
    @IBOutlet weak var passwordHideButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var confirmPasswordField: PaddedTextField!
    @IBOutlet weak var passwordField: PaddedTextField!
    @IBOutlet weak var emailField: PaddedTextField!
    @IBOutlet weak var nameField: PaddedTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameField.layer.cornerRadius = 15
        self.emailField.layer.cornerRadius = 15
        self.passwordField.layer.cornerRadius = 15
        self.confirmPasswordField.layer.cornerRadius = 15
        self.createAccountButton.layer.cornerRadius = 26
        
        passwordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        confirmPasswordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObserver()
    }
    
    @IBAction func createAccountAction(_ sender: Any) {
        guard let password = passwordField.text,
              let email = emailField.text,
              let name = nameField.text,
              let confirmPassword = confirmPasswordField.text else {
            return
        }
        
        if !isValidEmail(email: email) {
            showAlert(message: "Please enter a valid email address.")
            return
        }
        
        if password.count < 8 {
            showAlert(message: "Password must be at least 8 characters.")
            return
        }
        
        if password != confirmPassword {
            showAlert(message: "Password and Confirm password must be equal.")
            return
        }
        
        guard let url = createURL() else {
            return
        }
        
        let parameters: [String: Any] = [
            "name": name,
            "email": email,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            return
        }
        
        let request = createURLRequest(url: url, jsonData: jsonData)
        
        if password == confirmPassword {
            performURLRequest(request)
        }
    }
    
    private func createURL() -> URL? {
        guard let encodedURL = URL(string: "http://ec2-34-248-7-102.eu-west-1.compute.amazonaws.com:8080/auth/signup?type=customer")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            return nil
        }
        return url
    }
    
    private func createURLRequest(url: URL, jsonData: Data) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func performURLRequest(_ request: URLRequest) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                // Print the response data as a string
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Received data: \(responseString)")
                }
                
                guard !data.isEmpty else {
                    print("Error: Empty data received")
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print("Response JSON: \(json)")
                    } else {
                        print("Failed to parse JSON")
                    }
                    
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP status code: \(httpResponse.statusCode)")
                
                if (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        self.navigateToOTPViewController()
                    }
                } else {
                    print("Unsuccessful HTTP status code: \(httpResponse.statusCode)")
                }
            }
        }
        print("Starting login task")
        task.resume()
    }
    
    private func navigateToOTPViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let otpVC = storyboard.instantiateViewController(withIdentifier: "otpConfirmVC") as! ConfirmOTPViewController
        otpVC.name = nameField.text
        otpVC.email = emailField.text
        otpVC.password = passwordField.text
        navigationController?.pushViewController(otpVC, animated: true)
    }
    
    @IBAction func passwordHideAction(_ sender: Any) {
        togglePasswordVisibility(for: passwordField, with: passwordHideButton)
    }
    
    @IBAction func confirmPasswordHideAction(_ sender: Any) {
        togglePasswordVisibility(for: confirmPasswordField, with: confirmPasswordHideButton)
    }
    
    @IBAction func unwindToRegisterViewController(segue: UIStoryboardSegue) {}
}
