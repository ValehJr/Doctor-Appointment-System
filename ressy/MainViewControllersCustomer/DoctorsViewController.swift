//
//  DoctorsViewController.swift
//  ressy
//
//  Created by Valeh Ismayilov on 11.12.23.
//

import UIKit

class DoctorsViewController: UIViewController {
    
    @IBOutlet weak var doctorCollectionView: UICollectionView!
    
    var doctors:[Doctor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doctorCollectionView.dataSource = self
        doctorCollectionView.delegate = self
        
        fetchDoctors()
    }
    
    func fetchDoctors() {
        guard let url = URL(string: "http://ressy-home-service-alb-2048404408.eu-west-1.elb.amazonaws.com/doctor/all") else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
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
                        self.doctors = dataDict.compactMap { doctorData in
                            guard
                                let firstName = doctorData["firstname"] as? String,
                                let lastName = doctorData["lastname"] as? String,
                                let profession = doctorData["profession"] as? String,
                                let photoString = doctorData["photoBase64"] as? String,
                                let photoData = Data(base64Encoded: photoString) else {
                                print("Failed to parse data for doctor: \(doctorData)")
                                return nil
                            }
                            
                            guard let compressedImageData = self.compressImage(photoData) else {
                                print("Failed to compress image data for doctor: \(doctorData)")
                                return nil
                            }
                            
                            guard let image = UIImage(data: compressedImageData) else {
                                print("Failed to create UIImage for doctor: \(doctorData)")
                                return nil
                            }
                            
                            let doctor = Doctor(firstName: firstName, lastName: lastName, profession: profession, photo: compressedImageData, image: image,base64: photoString)
                            return doctor
                        }
                        
                        DispatchQueue.main.async {
                            self.doctorCollectionView.reloadData()
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
    
    
    func compressImage(_ imageData: Data) -> Data? {
        let compressionQuality: CGFloat = 0.2
        return UIImage(data: imageData)?.jpegData(compressionQuality: compressionQuality)
    }
}


extension DoctorsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doctors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "doctorID", for: indexPath) as! DoctorCollectionViewCell
        let doctor = doctors[indexPath.item]
        cell.layer.cornerRadius = 15
        cell.nameLabel.text = doctor.firstName + " " + doctor.lastName
        cell.specialityLabel.text = doctor.profession
        cell.profileImage.image = doctor.image
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
        cell.profileImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cell.profileImage.layer.masksToBounds = true
        cell.profileImage.contentMode = .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDoctor = doctors[indexPath.item]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let doctorVC = storyboard.instantiateViewController(withIdentifier: "doctorVC") as! DoctorViewController
        doctorVC.selectedDoctor = selectedDoctor
        navigationController?.pushViewController(doctorVC, animated: true)
    }
}
