//
//  RegisterViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 19.11.23.
//

import UIKit

class RegisterCustomerViewController: UIViewController {
    
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var confirmPasswordHideButton: UIButton!
    @IBOutlet weak var passwordHideButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var confirmPasswordField: PaddedTextField!
    @IBOutlet weak var passwordField: PaddedTextField!
    @IBOutlet weak var emailField: PaddedTextField!
    @IBOutlet weak var surnameField: PaddedTextField!
    @IBOutlet weak var nameField: PaddedTextField!
    
    let registerModel = RegisterCustomerModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAccountButton.clipsToBounds = true
        
        self.nameField.layer.cornerRadius = 15
        self.surnameField.layer.cornerRadius = 15
        self.emailField.layer.cornerRadius = 15
        self.passwordField.layer.cornerRadius = 15
        self.confirmPasswordField.layer.cornerRadius = 15
        self.createAccountButton.layer.cornerRadius = 26
        
        passwordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        confirmPasswordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        
        let textColor = UIColor(red: 154/255.0, green: 162/255.0, blue: 178/255.0, alpha: 1)
        
        nameField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        surnameField.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        emailField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        
        hideKeyboardWhenTappedAround()
        
        createAccountButton.alpha = 0.75
        
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
        let user = Customer(firstName: nameField.text!, lastName: surnameField.text!, email: emailField.text!, password: passwordField.text!)
        
        let validationResult = registerModel.validateUserInput(user: user, confirmPassword: confirmPasswordField.text)
        
        if let error = validationResult {
            showAlert(message: error)
            return
        }
        
        registerModel.registerUser(user: user) { success in
            if success {
                DispatchQueue.main.async {
                    self.navigateToOTPViewController()
                }
            } else {
                self.showAlert(message: "Unable to create!")
            }
        }
    }
    
    private func navigateToOTPViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let otpVC = storyboard.instantiateViewController(withIdentifier: "otpConfirmVC") as! ConfirmOTPViewController
        otpVC.name = nameField.text
        otpVC.email = emailField.text
        otpVC.surname = surnameField.text
        otpVC.password = passwordField.text
        otpVC.registrationType = .customer
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
