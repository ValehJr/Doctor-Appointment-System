//
//  ForgetPasswordViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 24.11.23.
//

import UIKit

class ForgetPasswordViewController: UIViewController {
    
    @IBOutlet weak var forgetLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailField: PaddedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.layer.cornerRadius = 15
        self.sendButton.layer.cornerRadius = 26
        
        hideKeyboardWhenTappedAround()
        
        sendButton.alpha = 0.75
        
        let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
        let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
        
        addGradientToView(sendButton, firstColor: firstColor, secondColor: secondColor)
        
        let textColor = UIColor(red: 154/255.0, green: 162/255.0, blue: 178/255.0, alpha: 1)
        emailField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
        let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
        
        addGradientToView(sendButton, firstColor: firstColor, secondColor: secondColor)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
        guard let email = emailField.text else {
            print ("Failed")
            return
        }
        
        if !isValidEmail(email: email) {
            showAlert(message: "Please enter a valid email address.")
            return
        }
        
        let url = URL(string: GlobalConstants.apiUrl + "/auth/forgot?email=\(email)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else {
                
                DispatchQueue.main.async {
                    self.navigateToOTPViewController()
                    self.showSuccess(message: "The reset link was sent to your email. Please check your inbox or spam!")
                }
            }
        }.resume()
    }
    
    
    
    private func navigateToOTPViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let otpVC = storyboard.instantiateViewController(withIdentifier: "otpForgetVC") as! ForgetOTPViewController
        otpVC.email = emailField.text
        navigationController?.pushViewController(otpVC, animated: true)
    }
}

