//
//  AppointmentModel.swift
//  ressy
//
//  Created by Valeh Ismayilov on 16.12.23.
//

import Foundation
import UIKit

struct Appointment: Codable {
    let doctorName: String
    let doctorProfession: String
    let doctorEmail:String
    let scheduleDate: String
    let scheduleTime:String
    let patientName: String
    let patientGender: String
    let patientAge: Int
    let patientProblem: String
    let doctorPhotoBase64: String
    var image:UIImage?
    
    enum CodingKeys: String, CodingKey {
        case doctorName, doctorProfession,doctorEmail ,scheduleDate, scheduleTime ,patientName, patientGender, patientAge, patientProblem, doctorPhotoBase64
    }
}
struct CancellledAppointment: Codable {
    let doctorName: String
    let doctorProfession: String
    let doctorEmail:String
    let appointmentDate: String // Update field name
    let appointmentTime: String 
    let patientName: String
    let patientGender: String
    let patientAge: Int
    let patientProblem: String
    
    enum CodingKeys: String, CodingKey {
        case doctorName, doctorProfession, doctorEmail ,appointmentDate, appointmentTime ,patientName, patientGender, patientAge, patientProblem
    }
}
