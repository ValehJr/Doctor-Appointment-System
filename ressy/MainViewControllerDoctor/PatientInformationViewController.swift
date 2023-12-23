//
//  PatientInformationViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 22.12.23.
//

import UIKit

class PatientInformationViewController: UIViewController {

    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var problemView: UITextView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var appointment: Appointment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let appointment = appointment {
            nameLabel.text = ":   " + appointment.patientName
            ageLabel.text = ":   " + "\(appointment.patientAge)"
            dateLabel.text = appointment.scheduleDate
            timeLabel.text = appointment.scheduleTime
            genderLabel.text = ":   " + appointment.patientGender
            problemView.text = ":   " + appointment.patientProblem
            
            timeLabel.text = String(timeLabel.text!.prefix(5))
        }
    }


}
