//
//  RegisterProfessionalViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 21.11.23.
//

import UIKit

class RegisterProfessionalViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var confirmPasswordHideButton: UIButton!
    @IBOutlet weak var passwordHideButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var fieldChooseField: PaddedTextField!
    @IBOutlet weak var confirmPasswordField: PaddedTextField!
    @IBOutlet weak var passwordField: PaddedTextField!
    @IBOutlet weak var emailField: PaddedTextField!
    @IBOutlet weak var nameField: PaddedTextField!
    
    let fields = ["Doctor","Barber","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameField.layer.cornerRadius = 15
        self.emailField.layer.cornerRadius = 15
        self.passwordField.layer.cornerRadius = 15
        self.confirmPasswordField.layer.cornerRadius = 15
        self.fieldChooseField.layer.cornerRadius = 15
        self.createAccountButton.layer.cornerRadius = 26
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        fieldChooseField.inputView = pickerView
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "otpVC" {
            if let destinationVC = segue.destination as? OTPViewController {
                destinationVC.name = nameField.text
                destinationVC.email = emailField.text
                destinationVC.password = passwordField.text
            }
        }
    }
    
    @IBAction func createAccountAction(_ sender: Any) {
        guard let password = passwordField.text,
              let mail = emailField.text, let name = nameField.text,let confirmPassword = confirmPasswordField.text else {
            return
        }
        
        guard let encodedURL = URL(string: "http://ec2-34-241-107-14.eu-west-1.compute.amazonaws.com:8080/auth/signup?type=customer")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            return
        }
        
        let parameters: [String: Any] = [
            "name": name,
            "email": mail,
            "password": password
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            return
        }
        
        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.httpBody = jsonData

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if password == confirmPassword {
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
                            let otpVC = storyboard.instantiateViewController(withIdentifier: "otpVC") as! OTPViewController
                            self.navigationController?.pushViewController(otpVC, animated: true)
                        }
                    } else {
                        print("Unsuccessful HTTP status code: \(httpResponse.statusCode)")
                    }
                }
            }
            print("Starting data task")
            task.resume()
        } else {
            print("Password and confirm password must be equal!")
        }
    }
    
    @IBAction func hidePasswordAction(_ sender: Any) {
        if passwordField.isSecureTextEntry{
            passwordField.isSecureTextEntry = false
            passwordHideButton.setBackgroundImage(UIImage(named: "eyeIcon"), for: .normal)
        } else {
            passwordField.isSecureTextEntry = true
            passwordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        }
    }
    
    @IBAction func hideConfirmPasswordAction(_ sender: Any) {
        if confirmPasswordField.isSecureTextEntry{
            confirmPasswordField.isSecureTextEntry = false
            confirmPasswordHideButton.setBackgroundImage(UIImage(named: "eyeIcon"), for: .normal)
        } else {
            confirmPasswordField.isSecureTextEntry = true
            confirmPasswordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fields.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fields[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fieldChooseField.text = fields[row]
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
}
