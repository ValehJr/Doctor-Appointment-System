//
//  OTPViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 21.11.23.
//

import UIKit
import SwiftKeychainWrapper


class ConfirmOTPViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var fourthField: UITextField!
    @IBOutlet weak var thirdField: UITextField!
    @IBOutlet weak var secondField: UITextField!
    @IBOutlet weak var firstField: UITextField!
    
    var name:String?
    var surname:String?
    var email:String?
    var password:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstField.delegate = self
        secondField.delegate = self
        thirdField.delegate = self
        fourthField.delegate = self
        
        firstField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        secondField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        thirdField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        fourthField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.submitButton.layer.cornerRadius = 26
        
        let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
        let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
        
        addGradientToView(submitButton, firstColor: firstColor, secondColor: secondColor)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
        let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
        
        addGradientToView(submitButton, firstColor: firstColor, secondColor: secondColor)
    }
    
    
    func textFieldDidDelete() {
        print("delete")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = (textField.text?.count ?? 0) + string.count - range.length
        return newLength <= 1
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            switch textField {
            case firstField:
                secondField.becomeFirstResponder()
            case secondField:
                thirdField.becomeFirstResponder()
            case thirdField:
                fourthField.becomeFirstResponder()
            case fourthField:
                return
            default:
                break
            }
        } else {
            switch textField {
            case secondField:
                firstField.becomeFirstResponder()
            case thirdField:
                secondField.becomeFirstResponder()
            case fourthField:
                thirdField.becomeFirstResponder()
            default:
                break
            }
        }
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        let enteredOTP = "\(firstField.text ?? "")\(secondField.text ?? "")\(thirdField.text ?? "")\(fourthField.text ?? "")"
        
        guard let password = self.password,let email = self.email, let name = self.name,let surname = self.surname ,!enteredOTP.isEmpty
        else {
            print("Failde")
            return
        }
        
        print(enteredOTP)
        
        guard let encodedURL = URL(string: GlobalConstants.apiUrl + "/auth/signup?type=customer&otp=\(enteredOTP)")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            return
        }
        
        let parameters: [String: Any] = [
            "firstname": name,
            "lastname":surname,
            "email": email,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
                        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarVC") as? UITabBarController
                        self.view.window?.rootViewController = homeViewController
                        self.view.window?.makeKeyAndVisible()
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
