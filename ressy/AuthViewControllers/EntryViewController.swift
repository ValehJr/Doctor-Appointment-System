//
//  ViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 19.11.23.
//

import UIKit

class EntryViewController: UIViewController {
    
    @IBOutlet var backView: UIView!
    @IBOutlet weak var singInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var privacyLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var logoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabels()
        setupButtons()
        checkJWTAndNavigateToMain()
        addGradientToView()
    }

    func setupLabels() {
        termsLabel.isUserInteractionEnabled = true
        privacyLabel.isUserInteractionEnabled = true

        setupTapGesture(for: termsLabel, with: "Terms and Conditions")
        setupTapGesture(for: privacyLabel, with: "Privacy Policy")
    }

    func setupTapGesture(for label: UILabel, with keyword: String) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_:)))
        tapGesture.numberOfTapsRequired = 1

        let text = label.text ?? ""
        let attributedString = NSMutableAttributedString(string: text)

        let range = (text as NSString).range(of: keyword)
        attributedString.addAttributes([.font: UIFont.boldSystemFont(ofSize: 12), .underlineStyle: NSUnderlineStyle.single.rawValue], range: range)

        label.attributedText = attributedString
        label.addGestureRecognizer(tapGesture)
    }

    func setupButtons() {
        createAccountButton.clipsToBounds = true
        singInButton.clipsToBounds = true

        createAccountButton.layer.cornerRadius = 26

        singInButton.layer.cornerRadius = 26
        singInButton.layer.borderColor = UIColor.white.cgColor
        singInButton.layer.borderWidth = 1
    }

    func addGradientToView() {
        addGradientToView(backView, firstColor: UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0), secondColor: UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0))
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
    @IBAction func unwindToEntryViewController(segue: UIStoryboardSegue) {}
}
