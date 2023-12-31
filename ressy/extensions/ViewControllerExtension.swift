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
    
    

    enum RegistrationType {
        case customer
        case doctor
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
    
    func navigateToMainViewControllerCustomer() {
        DispatchQueue.main.async {
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarVC") as? UITabBarController
            self.view.window?.rootViewController = homeViewController
            self.view.window?.makeKeyAndVisible()
        }
    }
    func navigateToMainViewControllerDoctor() {
        DispatchQueue.main.async {
            let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: "doctorTabBar") as? UITabBarController
            self.view.window?.rootViewController = homeViewController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    func checkJWTAndNavigateToMain() {
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken"),
              let userRole = KeychainWrapper.standard.string(forKey: "userRole") else {
            print("JWT token or user role not found in Keychain")
            return
        }
        
        do {
            let jwt = try decode(jwt: jwtToken)
            if jwt.expired {
                print("JWT token has expired")
            } else {
                print("JWT token is valid")
                DispatchQueue.main.async {
                    if userRole.lowercased() == "customer" {
                        self.navigateToMainViewControllerCustomer()
                    } else if userRole.lowercased() == "doctor" {
                        self.navigateToMainViewControllerDoctor()
                    } else {
                        print("Unknown role: \(userRole)")
                    }
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
    
    func addGradientToView(_ view: UIView, firstColor: UIColor, secondColor: UIColor) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        gradientLayer.frame = view.bounds
        
        view.clipsToBounds = true
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func changeBackButton() {
        let backButtonBlack = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorImage = backButtonBlack
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonBlack
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
    }
    
    func customizeBackButton() {
        let backButton = UIBarButtonItem()
        backButton.title = ""
        
        let backButtonImage = UIImage(named: "backIcon")?.withRenderingMode(.alwaysOriginal)
        backButton.image = backButtonImage
        
        backButton.target = self
        backButton.action = #selector(backButtonPressed)
        
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButtonPressed() {
        // Navigate back to the previous view controller
        self.navigationController?.popViewController(animated: true)
    }
    
}
