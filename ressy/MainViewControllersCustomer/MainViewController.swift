//
//  MainViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 23.11.23.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var doctorSpecialityCollectionView: UICollectionView!
    @IBOutlet weak var topDoctorsCollectionView: UICollectionView!
    @IBOutlet weak var upcomingAppointmentCollectionView: UICollectionView!
    @IBOutlet weak var searchField: PaddedTextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let imageNames = ["General","Dentist","Otology","Cardiology","Intestine","Pediatric","Herbal","More"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        upcomingAppointmentCollectionView.dataSource = self
        upcomingAppointmentCollectionView.delegate = self
        
        upcomingAppointmentCollectionView.layer.cornerRadius = 15
        
        topDoctorsCollectionView.dataSource = self
        topDoctorsCollectionView.delegate = self
        topDoctorsCollectionView.backgroundColor = .white
        
        doctorSpecialityCollectionView.dataSource = self
        doctorSpecialityCollectionView.delegate = self
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar when leaving the view controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeIcon"), selectedImage: UIImage(named: "homeIconSelected"))
        self.tabBarItem = tabBarItem
    }
    
    @IBAction func seeAllSpecialitiesAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let doctorVC = storyboard.instantiateViewController(withIdentifier: "doctorsVC") as! DoctorsViewController
        navigationController?.pushViewController(doctorVC, animated: true)
    }
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == upcomingAppointmentCollectionView {
            return CGSize(width: upcomingAppointmentCollectionView.bounds.width, height: collectionView.bounds.height)
        } else if collectionView == topDoctorsCollectionView {
            return CGSize(width: topDoctorsCollectionView.bounds.width, height: 100)
        } else if collectionView == doctorSpecialityCollectionView {
            return CGSize(width: doctorSpecialityCollectionView.bounds.width, height: 82)
        }
        return CGSize.zero
    }
}




extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == upcomingAppointmentCollectionView {
            return 1
        }
        
        if collectionView == topDoctorsCollectionView {
            return 5
        }
        if collectionView == doctorSpecialityCollectionView {
            return imageNames.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == upcomingAppointmentCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upcomingAppointmentID", for: indexPath) as! UpcomingAppointmentCollectionViewCell
            let firstColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
            let secondColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
            addGradientToView(cell.backgorundView, firstColor: firstColor, secondColor: secondColor)
            cell.calendarView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.09)
            cell.timeView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.09)
            cell.calendarView.layer.cornerRadius = 15
            cell.timeView.layer.cornerRadius = 15
            cell.backgorundView.frame = cell.bounds
            return cell
        }
        if collectionView == topDoctorsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topDoctorsID", for: indexPath) as! TopDoctorsCollectionViewCell
            cell.backgroundColor = UIColor.white
            cell.nameLabel.text = "Valeh"
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
}
