//
//  AppointmentViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 27.11.23.
//

import UIKit

class AppointmentsViewController: UIViewController {
    
    @IBOutlet weak var appointmentCollectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let textColorSelected = UIColor(red: 163/255.0, green: 194/255.0, blue: 249/255.0, alpha: 1.0)
    let textColor = UIColor(red: 129/255.0, green: 137/255.0, blue: 153/255.0, alpha: 1.0)
    let firstGradColor = UIColor(red: 157/255.0, green: 206/255.0, blue: 255/255.0, alpha: 1.0)
    let secondGradColor = UIColor(red: 146/255.0, green: 153/255.0, blue: 253/255.0, alpha: 1.0)
    let thirdGradColor = UIColor(red: 159/255.0, green: 184/255.0, blue: 249/255.0, alpha: 1.0)
    
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
        
        
        
        let tabBarItem = UITabBarItem(title: "Appointment", image: UIImage(named: "calendarIcon"), selectedImage: UIImage(named: "calendarIcon"))
        self.tabBarItem = tabBarItem
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tabBarItem = UITabBarItem(title: "Appointment", image: UIImage(named: "calendarIcon"), selectedImage: UIImage(named: "calendarIcon"))
        self.tabBarItem = tabBarItem
    }
    
    @IBAction func segmentControlAction(_ sender: Any) {
        switch segmentControl.selectedSegmentIndex{
        case 0:
            print("Upcoming")
            appointmentCollectionView.reloadData()
        case 1:
            print("Completed")
            appointmentCollectionView.reloadData()
        case 2:
            print("Cancelled")
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
}

extension AppointmentsViewController:UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "doctorsID", for: indexPath) as! AppointmentCollectionViewCell
        let borderColor = UIColor(red: 237/255.0, green: 52/255.0, blue: 67/255.0, alpha: 1.0)
        cell.nameLabel.text = "Valeh"
        cell.firstButton.layer.borderWidth = 1
        cell.firstButton.layer.borderColor = borderColor.cgColor
        cell.firstButton.layer.cornerRadius = 16
        cell.secondButton.layer.cornerRadius = 16
        cell.profileImage.layer.cornerRadius =  cell.profileImage.frame.size.width / 2
        cell.profileImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cell.profileImage.layer.masksToBounds = true
        cell.profileImage.contentMode = .scaleAspectFill
        cell.profileImage.image = UIImage(named: "heart")
        cell.layer.cornerRadius = 15
        DispatchQueue.main.async {
            switch self.segmentControl.selectedSegmentIndex {
            case 0:
                cell.firstButton.isHidden = false
                cell.secondButton.isHidden = false
            case 1:
                cell.firstButton.isHidden = true
                cell.secondButton.isHidden = false
            case 2:
                cell.firstButton.isHidden = true
                cell.secondButton.isHidden = false
            default:
                break
            }
        }

        return cell
    }
}
