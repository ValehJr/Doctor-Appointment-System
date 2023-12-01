//
//  imagePicker.swift
//  ressy
//
//  Created by Valeh Ismayilov on 28.11.23.
//

import UIKit
import SwiftKeychainWrapper

extension UIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            print("Failed to get the original image")
            dismiss(animated: true, completion: nil)
            return
        }

        print("Image picked")
        saveImageToBase64AndSendToServer(image: image)
        dismiss(animated: true, completion: nil)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func saveImageToBase64AndSendToServer(image: UIImage) {
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }

        let token = jwtToken

        guard let imageData = image.pngData() else {
            print("Failed to convert image to data")
            return
        }

        let imageStr = imageData.base64EncodedString(options: [])

        let apiUrl = "http://ec2-34-248-7-102.eu-west-1.compute.amazonaws.com:8080/user/photo"

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
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Received data: \(responseString)")
                    }
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: [])
                        if let jsonDict = json as? [String: Any] {
                            print("Response JSON: \(jsonDict)")
                        } else {
                            print("Failed to parse JSON")
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                    }
                } else {
                }
            }
            task.resume()
        } catch {
            print("Error converting parameters to JSON: \(error)")
        }
    }

    
    func getImageFromServerAndDisplayInImageView(imageView: UIImageView) {
        // Replace this URL with the actual URL endpoint to retrieve the image
        let apiUrl = "http://ec2-34-248-7-102.eu-west-1.compute.amazonaws.com:8080/user/photo"
        
        guard let url = URL(string: apiUrl) else {
            print("Invalid URL")
            return
        }
        
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            return
        }
        
        let token = jwtToken
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                // Print the received data for debugging purposes
                print("Received base64 string: \(String(data: data, encoding: .utf8) ?? "")")
                
                if let base64String = String(data: data, encoding: .utf8),
                   let decodedData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
                   let image = UIImage(data: decodedData) {
                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        imageView.image = image
                    }
                } else {
                    print("Failed to decode base64 string or create image")
                }
            } else {
                print("Failed to get image data")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP status code: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
    
}
