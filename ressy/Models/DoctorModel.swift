//
//  DoctorModel.swift
//  ressy
//
//  Created by Valeh Ismayilov on 14.12.23.
//

import Foundation
import UIKit

struct Doctor: Codable {
    var firstName: String
    var lastName: String
    var profession: String
    var photo: Data?
    var image: UIImage? 
    
    enum CodingKeys: String, CodingKey {
        case firstName = "firstname"
        case lastName = "lastname"
        case profession
        case photo
    }
}
