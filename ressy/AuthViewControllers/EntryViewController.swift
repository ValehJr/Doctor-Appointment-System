//
//  ViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 19.11.23.
//

import UIKit

class EntryViewController: UIViewController {
    
    @IBOutlet weak var troubleButton: UIButton!
    @IBOutlet weak var singInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.termsLabel.isUserInteractionEnabled = true
        self.privacyLabel.isUserInteractionEnabled = true
        
        let termsGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_:)))
        termsGesture.numberOfTapsRequired = 1
        self.termsLabel.addGestureRecognizer(termsGesture)
        
        let termsText = "By tapping 'Sign in' you agree to our Terms and Conditions"
        let attributedStringForTerms = NSMutableAttributedString(string: termsText)
        
        let termsRange = (termsText as NSString).range(of: "Terms and Conditions")
        
        attributedStringForTerms.addAttributes([.font: UIFont.boldSystemFont(ofSize: 12), .underlineStyle: NSUnderlineStyle.single.rawValue], range: termsRange)
        
        self.termsLabel.attributedText = attributedStringForTerms
        
        let privacyGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_:)))
        privacyGesture.numberOfTapsRequired = 1
        self.privacyLabel.addGestureRecognizer(privacyGesture)
        
        let privacyText = "Learn how we process your data in our Privacy Policy"
        let attributedString = NSMutableAttributedString(string: privacyText)
        
        let privacyRange = (privacyText as NSString).range(of: "Privacy Policy")
        
        attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 12), .underlineStyle: NSUnderlineStyle.single.rawValue], range: privacyRange)
        
        self.privacyLabel.attributedText = attributedString
        
        self.createAccountButton.clipsToBounds = true
        self.singInButton.clipsToBounds = true
        
        self.createAccountButton.layer.cornerRadius = 26
        
        self.singInButton.layer.cornerRadius = 26
        self.singInButton.layer.borderColor = UIColor.white.cgColor
        self.singInButton.layer.borderWidth = 1
    }
    
    @IBAction func createAccountAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "accountTypeVC") as! AccountTypeViewController
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func singInAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func troubleAction(_ sender: Any) {
        
    }
    
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let termsText = self.termsLabel.text else { return }
        guard let privacyText = self.privacyLabel.text else { return }
        
        
        let privacyPolicyRange = (privacyText as NSString).range(of: "Privacy Policy")
        let termsRange = (termsText as NSString).range(of: "Terms and Conditions")
        
        print("Tap Location: \(gesture.location(in: gesture.view))")
        
        if gesture.didTapAttributedTextInLabel(label: self.privacyLabel, inRange: privacyPolicyRange) {
            print("user tapped on privacy policy text")
        } else if gesture.didTapAttributedTextInLabel(label: self.termsLabel, inRange: termsRange){
            print("user tapped on terms and conditions text")
        }
    }
    @IBAction func unwindToEntryViewController(segue: UIStoryboardSegue) {
    }
}
