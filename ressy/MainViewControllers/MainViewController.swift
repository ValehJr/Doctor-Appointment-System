//
//  MainViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 23.11.23.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var topDoctorsCollectionView: UICollectionView!
    @IBOutlet weak var doctorSpecialityCollectionView: UICollectionView!
    @IBOutlet weak var upcomingAppointmentCollectionView: UICollectionView!
    @IBOutlet weak var searchField: PaddedTextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let imageNames = ["pediatric","otology","intestine","herbal","general","dentist","cardiology","more"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        upcomingAppointmentCollectionView.dataSource = self
        upcomingAppointmentCollectionView.delegate = self
        
        doctorSpecialityCollectionView.dataSource = self
        doctorSpecialityCollectionView.delegate = self
        
        topDoctorsCollectionView.dataSource = self
        topDoctorsCollectionView.delegate = self
        
        profileImage.layer.cornerRadius = 24
        
        let tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeIcon"), selectedImage: UIImage(named: "homeIconSelected"))
        self.tabBarItem = tabBarItem
        
        fetchUserInfo { userInfo in
            if let userInfo = userInfo {
                DispatchQueue.main.async {
                    self.nameLabel.text = "\(userInfo.firstname) \(userInfo.lastname)"
                }
            } else {
                self.showAlert(message: "Unable to fetch your information!")
            }
            
        }
        
        self.retrieveImageFromServer { (image) in
            if let image = image {
                DispatchQueue.main.async {
                    self.profileImage.image = image
                }
            } else {
                print("Failed to retrieve image")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeIcon"), selectedImage: UIImage(named: "homeIconSelected"))
        self.tabBarItem = tabBarItem
    }
    
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == upcomingAppointmentCollectionView {
            return 1
        }
        if collectionView == doctorSpecialityCollectionView {
            return imageNames.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == upcomingAppointmentCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingAppointment", for: indexPath) as! UpcomingAppointmentCollectionViewCell
            cell.backgorundView.layer.cornerRadius = 15
            let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
            let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
            addGradientToView(cell.backgorundView, firstColor: firstColor, secondColor: secondColor)
            cell.calendarView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.09)
            cell.timeView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.09)
            cell.calendarView.layer.cornerRadius = 15
            cell.timeView.layer.cornerRadius = 15
            return cell
        }
        if collectionView == doctorSpecialityCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "doctorSpecialityID", for: indexPath) as! SpecialityDoctorsCollectionViewCell
            let imageName = imageNames[indexPath.item]
            cell.imageView.image = UIImage(named: imageName)
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension MainViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
