//
//  LoginViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 19.11.23.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var singInButton: UIButton!
    @IBOutlet weak var hidePasswordButton: UIButton!
    @IBOutlet weak var passwordField: PaddedTextField!
    @IBOutlet weak var emailField: PaddedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.layer.cornerRadius = 15
        self.passwordField.layer.cornerRadius = 15
        self.singInButton.layer.cornerRadius = 26
        
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
    
    @IBAction func singInAction(_ sender: Any) {
        
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let forgetVC = storyboard.instantiateViewController(withIdentifier: "forgetPasswordVC") as! ForgetPasswordViewController
        self.navigationController?.pushViewController(forgetVC, animated: true)
        
    }
    @IBAction func hidePasswordAction(_ sender: Any) {
        if passwordField.isSecureTextEntry{
            passwordField.isSecureTextEntry = false
        } else {
            passwordField.isSecureTextEntry = true
        }
    }
    
    @IBAction func unwindToLoginViewController(segue: UIStoryboardSegue) {}
}
