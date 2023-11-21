//
//  RegisterProfessionalViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 21.11.23.
//

import UIKit

class RegisterProfessionalViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var fieldChooseField: PaddedTextField!
    @IBOutlet weak var confirmPasswordField: PaddedTextField!
    @IBOutlet weak var passwordField: PaddedTextField!
    @IBOutlet weak var emailField: PaddedTextField!
    @IBOutlet weak var nameField: PaddedTextField!
    
    let fields = ["Doctor","Barber","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameField.layer.cornerRadius = 15
        self.emailField.layer.cornerRadius = 15
        self.passwordField.layer.cornerRadius = 15
        self.confirmPasswordField.layer.cornerRadius = 15
        self.fieldChooseField.layer.cornerRadius = 15
        self.createAccountButton.layer.cornerRadius = 26
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        fieldChooseField.inputView = pickerView
        
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
    @IBAction func hidePasswordAction(_ sender: Any) {
        if passwordField.isSecureTextEntry{
            passwordField.isSecureTextEntry = false
        } else {
            passwordField.isSecureTextEntry = true
        }
    }
    
    @IBAction func hideConfirmPasswordAction(_ sender: Any) {
        if confirmPasswordField.isSecureTextEntry{
            confirmPasswordField.isSecureTextEntry = false
        } else {
            confirmPasswordField.isSecureTextEntry = true
        }
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
