//
//  imagePicker.swift
//  ressy
//
//  Created by Valeh Ismayilov on 28.11.23.
//

import UIKit
import SwiftKeychainWrapper

extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let fillViewController = self as? FillProfileViewController {
                fillViewController.profileImage.image = pickedImage
            }
            saveImageToServer(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveImageToServer(image: UIImage) {
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }
        
        let token = jwtToken
        
        guard let imageData = image.jpegData(compressionQuality: 0.3 ) else {
            print("Failed to convert image to data")
            return
        }
        
        let imageStr = imageData.base64EncodedString(options: [])
        
        let apiUrl = "http://ressy-user-service-708424409.eu-west-1.elb.amazonaws.com/user/photo"
        
        guard let url = URL(string: apiUrl) else {
            print("Invalid URL")
            return
        }
        
        let parameters: [String: Any] = [
            "photo": imageStr
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    print("Error: \(error!)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid HTTP response")
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    if let data = data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: [])
                            if let jsonDict = json as? [String: Any] {
                                print("Response JSON: \(jsonDict)")
                            } else {
                                print("Failed to parse JSON")
                            }
                        } catch {
                            print("Error parsing JSON: \(error)")
                        }
                    }
                } else {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Received data: \(responseString)")
                    }
                }
            }
            task.resume()
        } catch {
            print("Error converting parameters to JSON: \(error)")
        }
    }
    
    func retrieveImageFromServer(completion: @escaping (UIImage?) -> Void) {
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }
        
        let token = jwtToken
        
        let apiUrl = "http://ressy-user-service-708424409.eu-west-1.elb.amazonaws.com/user/photo"
        
        guard let url = URL(string: apiUrl) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                print("Error: \(error!)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                return
            }
            
            if let data = data{
                if let json = try? JSONSerialization.jsonObject(with: data, options: []),
                   let jsonDict = json as? [String: Any],
                   let imageDataString = jsonDict["data"] as? String,
                   let imageData = Data(base64Encoded: imageDataString),
                   let image = UIImage(data: imageData) {
                    
                    DispatchQueue.main.async {
                        completion(image)
                    }
                    
                }  else {
                    print("Failed to extract image data from JSON or create UIImage")
                    completion(nil)
                }
            } else {
                print("Server returned an error: \(httpResponse.statusCode)")
                completion(nil)
            }
            
            if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
            }
        }
        task.resume()
    }
    
}
