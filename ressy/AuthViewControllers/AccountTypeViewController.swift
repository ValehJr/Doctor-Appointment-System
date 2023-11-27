//
//  AccountTypeViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 21.11.23.
//

import UIKit

class AccountTypeViewController: UIViewController {

    @IBOutlet weak var professionalButton: UIButton!
    @IBOutlet weak var customerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customerButton.layer.cornerRadius = 26
        self.customerButton.layer.masksToBounds = true
        
        self.professionalButton.layer.cornerRadius = 26
        self.professionalButton.layer.borderColor = UIColor.white.cgColor
        self.professionalButton.layer.borderWidth = 1
    }
    
    @IBAction func customerButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "registerCustomerVC") as! RegisterCustomerViewController
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func professionalButtonAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "registerProfessionalVC") as! RegisterProfessionalViewController
        self.navigationController?.pushViewController(registerVC, animated: true)
        
    }
}
