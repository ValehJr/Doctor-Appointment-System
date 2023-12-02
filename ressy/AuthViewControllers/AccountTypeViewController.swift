//
//  AccountTypeViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 21.11.23.
//

import UIKit

class AccountTypeViewController: UIViewController {

    @IBOutlet var backView: UIView!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var professionalButton: UIButton!
    @IBOutlet weak var customerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.customerButton.layer.cornerRadius = 26
        self.customerButton.layer.masksToBounds = true
        
        self.professionalButton.layer.cornerRadius = 26
        self.professionalButton.layer.borderColor = UIColor.white.cgColor
        self.professionalButton.layer.borderWidth = 1
        
        addGradientToView(backView, firstColor:UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0) , secondColor: UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0))
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
