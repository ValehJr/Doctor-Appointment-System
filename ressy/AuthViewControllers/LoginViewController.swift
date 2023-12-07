//
//  LoginViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 19.11.23.
//

import UIKit
import SwiftKeychainWrapper
import JWTDecode

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var singInButton: UIButton!
    @IBOutlet weak var hidePasswordButton: UIButton!
    @IBOutlet weak var passwordField: PaddedTextField!
    @IBOutlet weak var emailField: PaddedTextField!
    
    let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.layer.cornerRadius = 15
        self.passwordField.layer.cornerRadius = 15
        self.singInButton.layer.cornerRadius = 26
        
        hideKeyboardWhenTappedAround()
        
        hidePasswordButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        
        singInButton.alpha = 0.75
        
        let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
        let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
        
        addGradientToView(singInButton, firstColor: firstColor, secondColor: secondColor)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
        let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
        
        addGradientToView(singInButton, firstColor: firstColor, secondColor: secondColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardObserver()
    }
    
    @IBAction func singInAction(_ sender: Any) {
        guard let password = passwordField.text,
              let email = emailField.text else {
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
        
        guard let url = createURL() else {
            return
        }
        
        let parameters: [String: Any] = [
            "username": email,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            return
        }
        
        let request = createURLRequest(url: url, jsonData: jsonData)
        
        performURLRequest(request)
    }
    
    private func createURL() -> URL? {
        guard let encodedURL = URL(string: GlobalConstants.apiUrl + "/auth/login")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
                        if let jwtToken = json["data"] as? String {
                            KeychainWrapper.standard.set(jwtToken, forKey: "jwtToken")
                        } else {
                            print("Failed to extract JWT token from JSON")
                        }
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
                        self.navigateToMainViewController()
                    }
                } else {
                    print("Unsuccessful HTTP status code: \(httpResponse.statusCode)")
                }
            }
        }
        print("Starting login task")
        task.resume()
    }
    
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forgetVC = storyboard.instantiateViewController(withIdentifier: "forgetPasswordVC") as! ForgetPasswordViewController
        self.navigationController?.pushViewController(forgetVC, animated: true)
        
    }
    
    @IBAction func hidePasswordAction(_ sender: Any) {
        togglePasswordVisibility(for: passwordField, with: hidePasswordButton)
    }
    
    @IBAction func unwindToLoginViewController(segue: UIStoryboardSegue) {}
    
}
