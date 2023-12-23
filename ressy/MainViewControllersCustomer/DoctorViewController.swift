//
//  DoctorViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 09.12.23.
//

import UIKit

class DoctorViewController: UIViewController {

    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var locationLabelTwo: UILabel!
    @IBOutlet weak var specialityLabelTwo: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var loactionLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var nameLabelTwo: UILabel!
    @IBOutlet weak var nameLabelOne: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    var selectedDoctor: Doctor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backView.layer.cornerRadius = 15
        
        bookButton.layer.cornerRadius = 26
        
        let name = "\(selectedDoctor?.firstName ?? "") \(selectedDoctor?.lastName ?? "")"
        nameLabelTwo.text = name
        specialityLabel.text = selectedDoctor?.profession
        specialityLabelTwo.text = selectedDoctor?.profession
        profileImage.image = selectedDoctor?.image
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        profileImage.layer.masksToBounds = true
        profileImage.contentMode = .scaleAspectFill
        
        descriptionTextView.backgroundColor = .white
        
        self.title = name
        let titleFont = UIFont(name: "Poppins-SemiBold", size: 18)
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: titleFont!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        changeNavBar(navigationBar:  self.navigationController!.navigationBar, to: .white,titleColor: .black)
        customizeBackButton()

    }
    
    func changeNavBar(navigationBar: UINavigationBar, to color: UIColor, titleColor: UIColor) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = color
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
    }
    
    @IBAction func bookAppointmentAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let informationVC = storyboard.instantiateViewController(withIdentifier: "informationVC") as! InformationViewController
        informationVC.selectedDoctor = selectedDoctor
        navigationController?.pushViewController(informationVC, animated: true)
    }
    
    

}
