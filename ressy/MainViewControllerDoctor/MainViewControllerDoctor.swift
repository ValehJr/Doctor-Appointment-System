//
//  MainViewControllerDoctor.swift
//  ressy
//
//  Created by Valeh Ismayilov on 15.12.23.
//

import UIKit
import SwiftKeychainWrapper

class MainViewControllerDoctor: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var upcommingCollectionView: UICollectionView!
    
    var appointments: [Appointment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        upcommingCollectionView.dataSource = self
        upcommingCollectionView.delegate = self
        upcommingCollectionView.backgroundColor = .white
        upcommingCollectionView.layer.cornerRadius = 15
        
        profileImage.layer.cornerRadius = 24
        
        let tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeIcon"), selectedImage: UIImage(named: "homeIconSelected"))
        self.tabBarItem = tabBarItem
        
        self.retrieveImageFromServer { (image) in
            if let image = image {
                DispatchQueue.main.async {
                    self.profileImage.image = image
                }
            } else {
                print("Failed to retrieve image")
            }
        }
        
        fetchUpcomingAppointment()
        fetchAndDisplayUserInfo()
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
    
    
    func fetchUpcomingAppointment() {
        guard let role = KeychainWrapper.standard.string(forKey: "userRole") else {
            return
        }
        
        guard let encodedURL = URL(string:"http://ressy-appointment-service-1978464186.eu-west-1.elb.amazonaws.com/appointment?type=Upcoming&user=\(role)")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
                            
                            guard let image = UIImage(data: photoData) else {
                                print("Failed to create UIImage for doctor: \(appointmentData)")
                                return nil
                            }
                            
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
                            self.upcommingCollectionView.reloadData()
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
extension MainViewControllerDoctor: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = collectionView.contentInset.left + collectionView.contentInset.right
          let cellWidth = collectionView.bounds.width - insets
          let cellHeight: CGFloat = 140
          return CGSize(width: cellWidth, height: cellHeight)
    }
}

extension MainViewControllerDoctor: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appointments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingAppointmentIDdoctor", for: indexPath) as! UpcomingAppointmentCollectionViewCell
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
        cell.nameLabel.text = appointment.patientName
        cell.dateLabel.text = appointment.scheduleDate
        cell.timeLabel.text = appointment.scheduleTime
        cell.timeLabel.text = String(appointment.scheduleTime.prefix(5))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let patientVC = storyboard.instantiateViewController(withIdentifier: "userInfoID") as! PatientInformationViewController
        patientVC.appointment = appointments[indexPath.item]
        navigationController?.pushViewController(patientVC, animated: true)
    }
}
