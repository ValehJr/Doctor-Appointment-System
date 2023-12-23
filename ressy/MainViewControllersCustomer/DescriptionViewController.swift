//
//  DescriptionViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 19.12.23.
//

import UIKit

class DescriptionViewController: UIViewController {
    
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var problemView: UITextView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var doctorView: UIView!
    @IBOutlet weak var doctorLocation: UILabel!
    @IBOutlet weak var doctorSpeciality: UILabel!
    @IBOutlet weak var doctorName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var doctorNameValue: String?
    var doctorSpecialityValue: String?
    var doctorEmailValue:String?
    var profileImageValue: UIImage?
    var ageValue: String?
    var genderValue: String?
    var dateValue: String?
    var timeValue: String?
    var problemValue:String?
    var fullName:String?
    
    var appointment:String?
    
    var selectedDoctor:Doctor?
    var doctors:[Doctor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doctorName.text = "Dr " + doctorNameValue!
        doctorSpeciality.text = doctorSpecialityValue
        profileImage.image = profileImageValue
        ageLabel.text = ":   " + ageValue!
        problemView.text = ":   " + problemValue!
        nameLabel.text = ":   " + fullName!
        genderLabel.text = ":   " + genderValue!
        dateLabel.text = dateValue
        timeLabel.text =  timeValue
        
        timeLabel.text = String(timeLabel.text!.prefix(5))
        
        doctorView.layer.cornerRadius = 15
        
        bookButton.layer.cornerRadius = 26
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
        
        if appointment == "upcomming" {
            self.bookButton.isHidden = true
        } else if appointment == "canceled" || appointment == "completed" {
            self.bookButton.isHidden = false
        }
        problemView.backgroundColor = .white
        
        fetchDoctors {
            self.checkForSelectedDoctor()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchDoctors {
            self.checkForSelectedDoctor()
        }
    }
    
    func fetchDoctors(completion: @escaping () -> Void) {
        guard let selectedSpecialty = doctorSpecialityValue else {
            completion()
            return
        }
        
        guard let encodedURL = URL(string:"http://ressy-home-service-alb-2048404408.eu-west-1.elb.amazonaws.com/doctor?profession=\(selectedSpecialty)")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            completion()
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion()
                return
            } else if let data = data {
                guard !data.isEmpty else {
                    print("Error: Empty data received")
                    completion()
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let dataDict = json["data"] as? [[String: Any]] {
                        self.doctors = dataDict.compactMap { doctorData in
                            guard
                                let firstName = doctorData["firstname"] as? String,
                                let lastName = doctorData["lastname"] as? String,
                                let doctorEmail = doctorData["email"] as? String,
                                let profession = doctorData["profession"] as? String,
                                let photoString = doctorData["photoBase64"] as? String,
                                let photoData = Data(base64Encoded: photoString) else {
                                print("Failed to parse data for doctor: \(doctorData)")
                                return nil
                            }
                            guard let image = UIImage(data: photoData) else {
                                print("Failed to create UIImage for doctor: \(doctorData)")
                                return nil
                            }
                            
                            let doctor = Doctor(firstName: firstName, lastName: lastName, profession: profession, photo: photoData, image: image, base64: photoString,email: doctorEmail)
                            return doctor
                        }
                        completion()
                    } else {
                        print("Failed to parse JSON")
                        completion()
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion()
                }
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
    func checkForSelectedDoctor() {
        guard let fullNameComponents = doctorNameValue?.components(separatedBy: " ") else {
            print("Failed to convert profile image to data or extract full name components")
            return
        }
        guard fullNameComponents.count >= 2 else {
            print("Invalid full name format")
            return
        }
        
        let firstName = fullNameComponents.first!
        let lastName = fullNameComponents.dropFirst().joined(separator: " ")
        
        for doctor in doctors {
            if doctor.firstName.lowercased() == firstName.lowercased(),
               doctor.lastName.lowercased() == lastName.lowercased(),
               doctor.email == doctorEmailValue,
               doctor.profession == doctorSpecialityValue{
                self.selectedDoctor = doctor
                break
            }
        }
    }
    
    
    @IBAction func bookAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let doctorVC = storyboard.instantiateViewController(withIdentifier: "doctorVC") as! DoctorViewController
        doctorVC.selectedDoctor = selectedDoctor
        navigationController?.pushViewController(doctorVC, animated: true)
    }
    
}
