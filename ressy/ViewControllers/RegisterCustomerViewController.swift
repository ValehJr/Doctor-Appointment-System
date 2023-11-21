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
        
    }
    
    @IBAction func passwordHideAction(_ sender: Any) {
        if passwordField.isSecureTextEntry{
            passwordField.isSecureTextEntry = false
        } else {
            passwordField.isSecureTextEntry = true
        }
    }
    
    @IBAction func confirmPasswordHideAction(_ sender: Any) {
        if confirmPasswordField.isSecureTextEntry{
            confirmPasswordField.isSecureTextEntry = false
        } else {
            confirmPasswordField.isSecureTextEntry = true
        }
    }
    
    @IBAction func unwindToRegisterViewController(segue: UIStoryboardSegue) {
    }
}
