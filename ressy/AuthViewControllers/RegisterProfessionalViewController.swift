//
//  RegisterProfessionalViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 21.11.23.
//

import UIKit

class RegisterProfessionalViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var confirmPasswordHideButton: UIButton!
    @IBOutlet weak var passwordHideButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var fieldChooseField: PaddedTextField!
    @IBOutlet weak var confirmPasswordField: PaddedTextField!
    @IBOutlet weak var passwordField: PaddedTextField!
    @IBOutlet weak var emailField: PaddedTextField!
    @IBOutlet weak var surnameField: PaddedTextField!
    @IBOutlet weak var nameField: PaddedTextField!
    
    let fields = ["Doctor","Barber","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAccountButton.clipsToBounds = true
        
        self.nameField.layer.cornerRadius = 15
        self.emailField.layer.cornerRadius = 15
        self.passwordField.layer.cornerRadius = 15
        self.confirmPasswordField.layer.cornerRadius = 15
        self.fieldChooseField.layer.cornerRadius = 15
        self.createAccountButton.layer.cornerRadius = 26
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        fieldChooseField.inputView = pickerView
        
        passwordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        confirmPasswordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        
        let textColor = UIColor(red: 154/255.0, green: 162/255.0, blue: 178/255.0, alpha: 1)
        
        nameField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        surnameField.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        emailField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        fieldChooseField.attributedPlaceholder = NSAttributedString(string: "Choose Field", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        
        hideKeyboardWhenTappedAround()
        
        let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
        let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
        
        addGradientToView(createAccountButton, firstColor: firstColor, secondColor: secondColor)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
        let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
        
        addGradientToView(createAccountButton, firstColor: firstColor, secondColor: secondColor)
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
              let surname = surnameField.text,
              let confirmPassword = confirmPasswordField.text,
              let field = fieldChooseField.text else {
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
            "firstname": name,
            "lastname":surname,
            "email": email,
            "field":field,
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
        guard let encodedURL = URL(string: GlobalConstants.apiUrl + "/auth/signup?type=customer")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
        otpVC.surname = surnameField.text
        otpVC.email = emailField.text
        otpVC.password = passwordField.text
        navigationController?.pushViewController(otpVC, animated: true)
    }

    
    @IBAction func hidePasswordAction(_ sender: Any) {
        togglePasswordVisibility(for: passwordField, with: passwordHideButton)
    }
    
    @IBAction func hideConfirmPasswordAction(_ sender: Any) {
        togglePasswordVisibility(for: confirmPasswordField, with: confirmPasswordHideButton)
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
}
