//
//  MainViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 23.11.23.
//

import UIKit
import SwiftKeychainWrapper

class MainViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var doctorSpecialityCollectionView: UICollectionView!
    @IBOutlet weak var upcomingAppointmentCollectionView: UICollectionView!
    @IBOutlet weak var searchField: SearchField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let imageNames = ["General","Dentist","Otology","Cardiology","Intestine","Pediatric","Herbal"]
    
    var appointments: [Appointment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUpcomingAppointmentCollectionView()
        configureDoctorSpecialityCollectionView()
        configureProfileImage()
        configureTabBarItem()
        configureTextField()
        fetchAndDisplayUserInfo()
        fetchAndDisplayProfileImage()
        doctorSpecialityCollectionView.isUserInteractionEnabled = true
        hideKeyboardWhenTappedAround()
        
        
    }
    
    func configureTextField() {
        let paddedField = SearchField()
        searchField.layer.cornerRadius = 15
        searchField = paddedField
        let textColor = UIColor(red: 154/255.0, green: 162/255.0, blue: 178/255.0, alpha: 1)
        searchField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: textColor])
    }
    
    func configureUpcomingAppointmentCollectionView() {
        upcomingAppointmentCollectionView.dataSource = self
        upcomingAppointmentCollectionView.delegate = self
        upcomingAppointmentCollectionView.layer.cornerRadius = 15
        upcomingAppointmentCollectionView.backgroundColor = .white
    }

    
    func configureDoctorSpecialityCollectionView() {
        doctorSpecialityCollectionView.dataSource = self
        doctorSpecialityCollectionView.delegate = self
        doctorSpecialityCollectionView.backgroundColor = .white
    }
    
    func configureProfileImage() {
        profileImage.layer.cornerRadius = 24
    }
    
    func configureTabBarItem() {
        let tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeIcon"), selectedImage: UIImage(named: "homeIconSelected"))
        self.tabBarItem = tabBarItem
    }
    
    func fetchAndDisplayUserInfo() {
        fetchUserInfo { userInfo in
            if let userInfo = userInfo {
                DispatchQueue.main.async {
                    self.nameLabel.text = "\(userInfo.firstname) \(userInfo.lastname)"
                }
            } else {
                self.showAlert(message: "Unable to fetch your information!")
            }
        }
    }
    
    func fetchAndDisplayProfileImage() {
        retrieveImageFromServer { (image) in
            if let image = image {
                DispatchQueue.main.async {
                    self.profileImage.image = image
                }
            } else {
                print("Failed to retrieve image")
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeIcon"), selectedImage: UIImage(named: "homeIconSelected"))
        self.tabBarItem = tabBarItem
        fetchUpcomingAppointment()
        fetchAndDisplayUserInfo()
    }
    
    @IBAction func seeAllSpecialitiesAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let doctorVC = storyboard.instantiateViewController(withIdentifier: "doctorsVC") as! DoctorsViewController
        navigationController?.pushViewController(doctorVC, animated: true)
    }
    
    func fetchUpcomingAppointment() {
        guard let role = KeychainWrapper.standard.string(forKey: "userRole") else {
            return
        }
        
        guard let encodedURL = URL(string:"http://ressy-appointment-service-1978464186.eu-west-1.elb.amazonaws.com/appointment?type=Upcoming&user=\(role)" )?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            return
        }
        
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            } else if let data = data {
                guard !data.isEmpty else {
                    print("Error: Empty data received")
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let dataDict = json["data"] as? [[String: Any]] {
                        self.appointments = dataDict.compactMap { appointmentData in
                            guard
                                let doctorName = appointmentData["doctorName"] as? String,
                                let doctorProfession = appointmentData["doctorProfession"] as? String,
                                let doctorEmail = appointmentData["doctorEmail"] as? String,
                                let scheduleDate = appointmentData["scheduleDate"] as? String,
                                let scheduleTime = appointmentData["scheduleTime"] as? String,
                                let patientName = appointmentData["patientName"] as? String,
                                let patientGender = appointmentData["patientGender"] as? String,
                                let patientAge = appointmentData["patientAge"] as? Int,
                                let patientProblem = appointmentData["patientProblem"] as? String,
                                let doctorPhotoBase64 = appointmentData["doctorPhoto"] as? String,
                                let photoData = Data(base64Encoded: doctorPhotoBase64) else {
                                print("Failed to parse data for appointment: \(appointmentData)")
                                return nil
                            }

                            let image = UIImage(data: photoData)
                            
                            let appointment = Appointment(
                                doctorName: doctorName,
                                doctorProfession: doctorProfession,
                                doctorEmail: doctorEmail,
                                scheduleDate: scheduleDate,
                                scheduleTime: scheduleTime,
                                patientName: patientName,
                                patientGender: patientGender,
                                patientAge: patientAge,
                                patientProblem: patientProblem,
                                doctorPhotoBase64: doctorPhotoBase64,
                                image:image
                            )
                            return appointment
                        }
                        DispatchQueue.main.async {
                            self.upcomingAppointmentCollectionView.reloadData()
                        }
                    } else {
                        print("Failed to parse JSON")
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
        }.resume()
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == upcomingAppointmentCollectionView {
            return CGSize(width: upcomingAppointmentCollectionView.bounds.width, height: collectionView.bounds.height)
        } else if collectionView == doctorSpecialityCollectionView {
            return CGSize(width: doctorSpecialityCollectionView.bounds.width, height:  collectionView.bounds.height)
        }
        return CGSize.zero
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == upcomingAppointmentCollectionView {
            return appointments.count
        }
        if collectionView == doctorSpecialityCollectionView {
            return imageNames.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == upcomingAppointmentCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingAppointmentID", for: indexPath) as! UpcomingAppointmentCollectionViewCell
            let appointment = appointments[indexPath.item]
            let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
            let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
            addGradientToView(cell.backgorundView, firstColor: firstColor, secondColor: secondColor)
            cell.calendarView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.09)
            cell.timeView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.09)
            cell.calendarView.layer.cornerRadius = 15
            cell.timeView.layer.cornerRadius = 15
            cell.backgorundView.frame = cell.bounds
            cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
            cell.profileImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.profileImage.layer.masksToBounds = true
            cell.profileImage.contentMode = .scaleAspectFill
            cell.nameLabel.text = "Dr " + appointment.doctorName
            cell.doctorLabel.text = appointment.doctorProfession
            cell.profileImage.image = appointment.image
            cell.dateLabel.text = appointment.scheduleDate
            cell.timeLabel.text = appointment.scheduleTime
            cell.timeLabel.text = String(appointment.scheduleTime.prefix(5))
            return cell
        }
        if collectionView == doctorSpecialityCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "specialityID", for: indexPath) as! SpecialityDoctorsCollectionViewCell
            let images = imageNames[indexPath.item]
            cell.imageView.image = UIImage(named: images)
            cell.doctorLabel.text = images
            
            if let widthConstraint = cell.imageView.constraints.first(where: { $0.identifier == "0x60000213ecb0" }) {
                widthConstraint.isActive = false
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == doctorSpecialityCollectionView {
            let selectedSpecialty = imageNames[indexPath.item]
            showDoctorsViewController(for: selectedSpecialty,isFromCellClick: true)
        }
    }
    func showDoctorsViewController(for specialty: String, isFromCellClick: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let doctorsVC = storyboard.instantiateViewController(withIdentifier: "doctorsVC") as! DoctorsViewController
        doctorsVC.selectedSpecialty = specialty
        doctorsVC.isFromCellClick = isFromCellClick
        navigationController?.pushViewController(doctorsVC, animated: true)
    }
}
