//
//  KeyboardHide.swift
//  ressy
//
//  Created by Valeh Ismayilov on 21.11.23.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import JWTDecode

extension UIViewController {
    
    struct UserInfo: Codable {
        let firstname: String
        let lastname: String
        let joinedSince: String
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showSuccess(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func togglePasswordVisibility(for textField: UITextField, with button: UIButton) {
        textField.isSecureTextEntry.toggle()
        
        let imageName = textField.isSecureTextEntry ? "closedEyeIcon" : "eyeIcon"
        button.setBackgroundImage(UIImage(named: imageName), for: .normal)
        button.setBackgroundImage(UIImage(named: imageName), for: .highlighted)
    }
    
    func navigateToMainViewController() {
        let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarVC") as? UITabBarController
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    func checkJWTAndNavigateToMain() {
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }
        
        do {
            let jwt = try decode(jwt: jwtToken)
            if jwt.expired {
                print("JWT token has expired")
            } else {
                print("JWT token is valid")
                DispatchQueue.main.async {
                    self.navigateToMainViewController()
                }
            }
        } catch {
            print("Failed to decode JWT token: \(error)")
        }
    }
    
    func addShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
    }
}
