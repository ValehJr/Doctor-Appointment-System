//
//  FillProfileViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 06.12.23.
//

import UIKit
import SwiftKeychainWrapper

class FillProfileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var genderField: PaddedTextField!
    @IBOutlet weak var dateField: PaddedTextField!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    let fields = ["Male","Female","Other"]

    var registrationType: RegistrationType?
    
    let datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.genderField.layer.cornerRadius = 15
        self.dateField.layer.cornerRadius = 15
        self.sendButton.layer.cornerRadius = 26
        self.profileImage.layer.cornerRadius = 24
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        
        genderField.inputView = pickerView
        
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        dateField.inputView = datePicker
        datePicker.maximumDate = Date()
        
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        profileImage.image = UIImage(named: "addImageIcon")
        
        hideKeyboardWhenTappedAround()
    }
    
    @IBAction func addImageAction(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        guard let gender = genderField.text, let date = dateField.text, !gender.isEmpty, !date.isEmpty else {
            showAlert(message: "All the fields must be filled in!")
            return
        }
        
        let placeholderImage = UIImage(named: "addImageIcon")
        guard let image = profileImage.image, image != placeholderImage else {
            showAlert(message: "Select the image!")
            return
        }
        
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }
        
        guard let encodedURL = URL(string: GlobalConstants.apiUrl + "/auth/details")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            return
        }
        
        let parameters: [String: Any] = [
            "gender": gender,
            "DateOfBirth": date
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    print("Error: \(error!)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid HTTP response")
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Received data: \(responseString)")
                    }
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: [])
                        if let jsonDict = json as? [String: Any] {
                            print("Response JSON: \(jsonDict)")
                            switch self.registrationType{
                            case .doctor:
                                self.navigateToMainViewControllerDoctor()
                            case .customer:
                                self.navigateToMainViewControllerCustomer()
                            case .none:
                                print("error")
                            }
                            
                        } else {
                            print("Failed to parse JSON")
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                }
            }
            task.resume()
        } catch {
            print("Error converting parameters to JSON: \(error)")
        }
        
    }
    
    @objc func datePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        dateField.text = dateFormatter.string(from: datePicker.date)
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
        genderField.text = fields[row]
    }
}
