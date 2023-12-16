//
//  ForgetOTPViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 26.11.23.
//

import UIKit

class ForgetOTPViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var descripLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var fourthField: UITextField!
    @IBOutlet weak var thirdField: UITextField!
    @IBOutlet weak var secondField: UITextField!
    @IBOutlet weak var firstField: UITextField!
    
    var email:String?
    
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
        
        submitButton.alpha = 0.75
        
        let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
        let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
        
        addGradientToView(submitButton, firstColor: firstColor, secondColor: secondColor)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
        let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
        
        addGradientToView(submitButton, firstColor: firstColor, secondColor: secondColor)
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
        guard let enteredOTP = combineOTPFields() else {
            print("Failed")
            return
        }
        
        guard let email = self.email else {
            print("Failed")
            return
        }
        
        print(enteredOTP)
        
        guard let url = buildURL(email: email, otp: enteredOTP) else {
            return
        }
        
        let parameters: [String: Any] = ["email": email]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            return
        }
        
        let request = buildURLRequest(url: url, jsonData: jsonData)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            self.handleDataTaskResponse(data: data, response: response, error: error, email: email)
        }
        
        print("Starting data task")
        task.resume()
    }

    private func combineOTPFields() -> String? {
        let enteredOTP = "\(firstField.text ?? "")\(secondField.text ?? "")\(thirdField.text ?? "")\(fourthField.text ?? "")"
        return enteredOTP.isEmpty ? nil : enteredOTP
    }

    private func buildURL(email: String, otp: String) -> URL? {
        guard let encodedURL = URL(string: GlobalConstants.apiUrl + "/auth/forgot?email=\(email)&otp=\(otp)")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            return nil
        }
        return url
    }

    private func buildURLRequest(url: URL, jsonData: Data) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func handleDataTaskResponse(data: Data?, response: URLResponse?, error: Error?, email: String) {
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
                    self.navigateToNewPasswordVC(email: email)
                }
            } else {
                print("Unsuccessful HTTP status code: \(httpResponse.statusCode)")
            }
        }
    }

    private func navigateToNewPasswordVC(email: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateViewController(withIdentifier: "newPasswordVC") as! CreateNewPasswordViewController
        createVC.email = email
        self.navigationController?.pushViewController(createVC, animated: true)
    }

    
}
