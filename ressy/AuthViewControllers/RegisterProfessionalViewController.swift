//
//  RegisterProfessionalViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 21.11.23.
//

import UIKit

class RegisterProfessionalViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var confirmPasswordHideButton: UIButton!
    @IBOutlet weak var passwordHideButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var fieldChooseField: PaddedTextField!
    @IBOutlet weak var confirmPasswordField: PaddedTextField!
    @IBOutlet weak var passwordField: PaddedTextField!
    @IBOutlet weak var emailField: PaddedTextField!
    @IBOutlet weak var surnameField: PaddedTextField!
    @IBOutlet weak var nameField: PaddedTextField!
    
    let fields = ["General","Dentist","Otology","Cardiology","Intestine","Pediatric","Herbal"]
    
    var registerModel = RegisterProfessionalModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureButton()
        configureTextFields()
        configurePickerView()
        configurePasswordHideButtons()
        configurePlaceholders()
        configureKeyboardDismissal()
        configureAlpha()
        configureGradient()
    }

    func configureButton() {
        createAccountButton.clipsToBounds = true
        createAccountButton.layer.cornerRadius = 26
    }

    func configureTextFields() {
        let cornerRadius: CGFloat = 15
        nameField.layer.cornerRadius = cornerRadius
        surnameField.layer.cornerRadius = cornerRadius
        emailField.layer.cornerRadius = cornerRadius
        passwordField.layer.cornerRadius = cornerRadius
        confirmPasswordField.layer.cornerRadius = cornerRadius
        fieldChooseField.layer.cornerRadius = cornerRadius
    }

    func configurePickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        fieldChooseField.inputView = pickerView
    }

    func configurePasswordHideButtons() {
        passwordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
        confirmPasswordHideButton.setBackgroundImage(UIImage(named: "closedEyeIcon"), for: .normal)
    }

    func configurePlaceholders() {
        let textColor = UIColor(red: 154/255.0, green: 162/255.0, blue: 178/255.0, alpha: 1)

        nameField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        surnameField.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        emailField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedString.Key.foregroundColor: textColor])
        fieldChooseField.attributedPlaceholder = NSAttributedString(string: "Choose Field", attributes: [NSAttributedString.Key.foregroundColor: textColor])
    }

    func configureKeyboardDismissal() {
        hideKeyboardWhenTappedAround()
    }

    func configureAlpha() {
        createAccountButton.alpha = 0.75
    }

    func configureGradient() {
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
        let user = Professional(firstName: nameField.text!, lastName: surnameField.text!, profession: fieldChooseField.text!, email: emailField.text! ,password: passwordField.text!)
        
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
        otpVC.profession = fieldChooseField.text
        otpVC.registrationType = .doctor
        navigationController?.pushViewController(otpVC, animated: true)
    }

    
    @IBAction func hidePasswordAction(_ sender: Any) {
        togglePasswordVisibility(for: passwordField, with: passwordHideButton)
    }
    
    @IBAction func hideConfirmPasswordAction(_ sender: Any) {
        togglePasswordVisibility(for: confirmPasswordField, with: confirmPasswordHideButton)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fields.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fields[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        fieldChooseField.text = fields[row]
    }
}
