//
//  InformationViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 14.12.23.
//

import UIKit

class InformationViewController: UIViewController {

    @IBOutlet weak var nextBtton: UIButton!
    @IBOutlet weak var genderField: PaddedTextField!
    @IBOutlet weak var problemView: UITextView!
    @IBOutlet weak var ageField: PaddedTextField!
    @IBOutlet weak var nameField: PaddedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        nameField.layer.cornerRadius = 15
        ageField.layer.cornerRadius = 15
        problemView.layer.cornerRadius = 15
        genderField.layer.cornerRadius = 15
        nextBtton.layer.cornerRadius = 24
        
        self.title = "Patient Detail"
        let titleFont = UIFont(name: "Poppins-SemiBold", size: 18)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: titleFont!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        changeNavBar(navigationBar:  self.navigationController!.navigationBar, to: .white,titleColor: .black)
        customizeBackButton()
        
        problemView.leftSpace()
        problemView.addPlaceholder("Describe your problem")
        
        
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
    
    func changeNavBar(navigationBar: UINavigationBar, to color: UIColor, titleColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let doctorVC = storyboard.instantiateViewController(withIdentifier: "appointmentVC") as! AppointmentViewController
        navigationController?.pushViewController(doctorVC, animated: true)
    }
    

}
