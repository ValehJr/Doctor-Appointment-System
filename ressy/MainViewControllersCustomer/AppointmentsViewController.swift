//
//  AppointmentViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 27.11.23.
//

import UIKit
import SwiftKeychainWrapper

class AppointmentsViewController: UIViewController {
    
    @IBOutlet weak var appointmentCollectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let textColorSelected = UIColor(red: 163/255.0, green: 194/255.0, blue: 249/255.0, alpha: 1.0)
    let textColor = UIColor(red: 129/255.0, green: 137/255.0, blue: 153/255.0, alpha: 1.0)
    let firstGradColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
    let secondGradColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
    let thirdGradColor = UIColor(red: 159/255.0, green: 184/255.0, blue: 249/255.0, alpha: 1.0)
    
    var appointments:[Appointment] = []
    var canceledAppointment: [CancellledAppointment] = []
    var canceledAppointments: [Appointment] = []
    var completedAppointment: [Appointment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = UIFont(name: "Poppins-SemiBold", size: 14.0)
        segmentControl.setTitleTextAttributes([.foregroundColor: textColorSelected, .font: font as Any], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: textColor, .font: font as Any], for: .normal)
        
        
        segmentControl.subviews.forEach { subview in
            subview.backgroundColor = .white
        }
        fixBackgroundSegmentControl(segmentControl)
        
        appointmentCollectionView.dataSource = self
        appointmentCollectionView.delegate = self
        
        appointmentCollectionView.layer.cornerRadius = 15
        
        let tabBarItem = UITabBarItem(title: "Appointment", image: UIImage(named: "calendarIcon"), selectedImage: UIImage(named: "calendarIcon"))
        self.tabBarItem = tabBarItem
        fetchUpcomingAppointment()
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
        let tabBarItem = UITabBarItem(title: "Appointment", image: UIImage(named: "calendarIcon"), selectedImage: UIImage(named: "calendarIcon"))
        self.tabBarItem = tabBarItem
        fetchUpcomingAppointment()
    }
    
    @IBAction func segmentControlAction(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex{
        case 0:
            fetchUpcomingAppointment()
            appointmentCollectionView.reloadData()
        case 1:
            fetchCompletedAppointmets()
            appointmentCollectionView.reloadData()
        case 2:
            fetchCanceledAppointmets()
            appointmentCollectionView.reloadData()
        default:
            break
        }
    }
    
    func fixBackgroundSegmentControl( _ segmentControl: UISegmentedControl){
        if #available(iOS 13.0, *) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                for i in 0...(segmentControl.numberOfSegments-1)  {
                    let backgroundSegmentView = segmentControl.subviews[i]
                    backgroundSegmentView.isHidden = true
                }
            }
        }
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
                            self.appointmentCollectionView.reloadData()
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
    
    func fetchCanceledAppointmets() {
        guard let role = KeychainWrapper.standard.string(forKey: "userRole") else {
            return
        }
        
        guard let encodedURL = URL(string:"http://ressy-appointment-service-1978464186.eu-west-1.elb.amazonaws.com/appointment?type=Cancelled&user=\(role)")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
                        self.canceledAppointments = dataDict.compactMap { appointmentData in
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
                            
                            self.appointmentCollectionView.reloadData()
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
    
    func fetchCompletedAppointmets() {
        guard let role = KeychainWrapper.standard.string(forKey: "userRole") else {
            return
        }
        guard let encodedURL = URL(string:"http://ressy-appointment-service-1978464186.eu-west-1.elb.amazonaws.com/appointment?type=Completed&user=\(role)")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
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
                        self.completedAppointment = dataDict.compactMap { appointmentData in
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
                            self.appointmentCollectionView.reloadData()
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
    
    func cancelAppointment(appointment: CancellledAppointment) {
        guard let url = URL(string: "http://ressy-appointment-service-1978464186.eu-west-1.elb.amazonaws.com/appointment/cancel") else {
            print("Invalid URL")
            return
        }
        
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(appointment)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
                if let data = data{
                    print(data)
                }
            }
            
            task.resume()
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
        }
    }
    
    
    
    @objc func cancelAppointmentButtonTapped(_ sender: UIButton) {
        if let cell = sender.superview {
            var currentView: UIView? = cell
            while currentView != nil && !(currentView is UICollectionViewCell) {
                currentView = currentView?.superview
            }
            
            if let cellSuperview = currentView as? UICollectionViewCell,
               let indexPath = appointmentCollectionView.indexPath(for: cellSuperview) {
                let appointmentToCancel = appointments[indexPath.item]
                
                let cancelledAppointment = CancellledAppointment(
                    doctorName: appointmentToCancel.doctorName,
                    doctorProfession: appointmentToCancel.doctorProfession,
                    doctorEmail: appointmentToCancel.doctorEmail,
                    appointmentDate: appointmentToCancel.scheduleDate,
                    appointmentTime: appointmentToCancel.scheduleTime,
                    patientName: appointmentToCancel.patientName,
                    patientGender: appointmentToCancel.patientGender,
                    patientAge: appointmentToCancel.patientAge,
                    patientProblem: appointmentToCancel.patientProblem
                )
                cancelAppointment(appointment: cancelledAppointment)
                appointments.remove(at: indexPath.item)
                canceledAppointment.append(cancelledAppointment)
                appointmentCollectionView.reloadData()
            }
        }
    }
}

extension AppointmentsViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.segmentControl.selectedSegmentIndex {
        case 0:
            return appointments.count
        case 1:
            return completedAppointment.count
        case 2:
            return canceledAppointments.count
        default:
            break
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "doctorsID", for: indexPath) as! AppointmentCollectionViewCell
        let borderColor = UIColor(red: 237/255.0, green: 52/255.0, blue: 67/255.0, alpha: 1.0)
        let backColor = UIColor(red: 146/255.0, green: 172/255.0, blue: 249/255.0, alpha: 1.0)
        cell.firstButton.layer.borderWidth = 1
        cell.firstButton.layer.borderColor = borderColor.cgColor
        cell.firstButton.layer.cornerRadius = 16
        cell.profileImage.layer.cornerRadius =  cell.profileImage.frame.size.width / 2
        cell.profileImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cell.profileImage.layer.masksToBounds = true
        cell.profileImage.contentMode = .scaleAspectFill
        cell.layer.cornerRadius = 15
        cell.backAppointmentView.layer.cornerRadius = 15
        cell.firstButton.addTarget(self, action: #selector(cancelAppointmentButtonTapped(_:)), for: .touchUpInside)
        DispatchQueue.main.async {
            switch self.segmentControl.selectedSegmentIndex {
            case 0:
                cell.firstButton.addTarget(self, action: #selector(self.cancelAppointmentButtonTapped(_:)), for: .touchUpInside)
                let upcomingAppointment = self.appointments[indexPath.item]
                cell.firstButton.isHidden = false
                cell.profileImage.image = upcomingAppointment.image
                cell.nameLabel.text = "Dr " + upcomingAppointment.doctorName
                cell.specialityLabel.text = upcomingAppointment.doctorProfession
                cell.dateLabel.text = upcomingAppointment.scheduleDate
            case 1:

                let completedAppointment = self.completedAppointment[indexPath.item]
                cell.firstButton.isHidden = true
                cell.nameLabel.text = "Dr " +  completedAppointment.doctorName
                cell.specialityLabel.text = completedAppointment.doctorProfession
                cell.dateLabel.text = completedAppointment.scheduleDate
                cell.profileImage.image = completedAppointment.image
            case 2:
                let cancelledAppointment = self.canceledAppointments[indexPath.item]
                cell.firstButton.isHidden = true
                cell.nameLabel.text = "Dr " +  cancelledAppointment.doctorName
                cell.specialityLabel.text = cancelledAppointment.doctorProfession
                cell.dateLabel.text = cancelledAppointment.scheduleDate
                cell.profileImage.image = cancelledAppointment.image
            default:
                break
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Click")
        DispatchQueue.main.async {
            switch self.segmentControl.selectedSegmentIndex {
            case 0:
                let upcomingAppointment = self.appointments[indexPath.item]
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let descripVC = storyboard.instantiateViewController(withIdentifier: "bookAgainID") as! DescriptionViewController
                descripVC.doctorNameValue = upcomingAppointment.doctorName
                descripVC.doctorSpecialityValue = upcomingAppointment.doctorProfession
                descripVC.doctorEmailValue = upcomingAppointment.doctorEmail
                descripVC.profileImageValue = upcomingAppointment.image
                descripVC.ageValue = String(upcomingAppointment.patientAge)
                descripVC.genderValue = upcomingAppointment.patientGender
                descripVC.dateValue = upcomingAppointment.scheduleDate
                descripVC.timeValue = upcomingAppointment.scheduleTime
                descripVC.fullName = upcomingAppointment.patientName
                descripVC.problemValue = upcomingAppointment.patientProblem
                descripVC.appointment = "upcomming"
                self.navigationController?.pushViewController(descripVC, animated: true)
            case 1:
                let completedAppointment = self.completedAppointment[indexPath.item]
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let descripVC = storyboard.instantiateViewController(withIdentifier: "bookAgainID") as! DescriptionViewController
                descripVC.doctorNameValue = completedAppointment.doctorName
                descripVC.doctorSpecialityValue = completedAppointment.doctorProfession
                descripVC.doctorEmailValue = completedAppointment.doctorEmail
                descripVC.profileImageValue = completedAppointment.image
                descripVC.ageValue = String(completedAppointment.patientAge)
                descripVC.genderValue = completedAppointment.patientGender
                descripVC.dateValue = completedAppointment.scheduleDate
                descripVC.timeValue = completedAppointment.scheduleTime
                descripVC.fullName = completedAppointment.patientName
                descripVC.problemValue = completedAppointment.patientProblem
                descripVC.appointment = "completed"
                self.navigationController?.pushViewController(descripVC, animated: true)
            case 2:
                let cancelledAppointment = self.canceledAppointments[indexPath.item]
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let descripVC = storyboard.instantiateViewController(withIdentifier: "bookAgainID") as! DescriptionViewController
                descripVC.doctorNameValue = cancelledAppointment.doctorName
                descripVC.doctorSpecialityValue = cancelledAppointment.doctorProfession
                descripVC.doctorEmailValue = cancelledAppointment.doctorEmail
                descripVC.profileImageValue = cancelledAppointment.image
                descripVC.ageValue = String(cancelledAppointment.patientAge)
                descripVC.genderValue = cancelledAppointment.patientGender
                descripVC.dateValue = cancelledAppointment.scheduleDate
                descripVC.timeValue = cancelledAppointment.scheduleTime
                descripVC.fullName = cancelledAppointment.patientName
                descripVC.problemValue = cancelledAppointment.patientProblem
                descripVC.appointment = "canceled"
                self.navigationController?.pushViewController(descripVC, animated: true)
                
            default:
                break
            }
        }
    }
}
