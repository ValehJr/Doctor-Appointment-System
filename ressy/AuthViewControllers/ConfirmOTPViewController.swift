//
//  OTPViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 21.11.23.
//

import UIKit

class ConfirmOTPViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var fourthField: UITextField!
    @IBOutlet weak var thirdField: UITextField!
    @IBOutlet weak var secondField: UITextField!
    @IBOutlet weak var firstField: UITextField!
    
    var name:String?
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
                textField.resignFirstResponder()
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
        
        guard let password = self.password,let email = self.email, let name = self.name, !enteredOTP.isEmpty
        else {
            print("Failde")
            return
        }
        
        print(enteredOTP)
        
        guard let encodedURL = URL(string: "http://ec2-34-248-7-102.eu-west-1.compute.amazonaws.com:8080/auth/signup?type=customer&otp=\(enteredOTP)")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
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
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainVC = storyboard.instantiateViewController(withIdentifier: "mainVC") as! MainViewController
                        self.navigationController?.pushViewController(mainVC, animated: true)
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