//
//  MainViewControllerExtension.swift
//  ressy
//
//  Created by Valeh Ismayilov on 03.12.23.
//

import UIKit
import SwiftKeychainWrapper

extension UIViewController {
    
    struct UserInfo: Codable {
        let firstname: String
        let lastname: String
        let joinedSince: String
    }
    
    func fetchUserInfo(completion: @escaping (UserInfo?) -> Void) {
        guard let url = createURLMain() else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        guard let jwtToken = KeychainWrapper.standard.string(forKey: "jwtToken") else {
            print("JWT token not found in Keychain")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        let token = jwtToken
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            } else if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Received data:\(responseString)")
                }
                guard !data.isEmpty else {
                    print("Error: Empty data received")
                    completion(nil)
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let dataDict = json["data"] as? [String: Any] {
                        let firstname = dataDict["firstname"] as? String ?? ""
                        let lastname = dataDict["lastname"] as? String ?? ""
                        let joinDate = dataDict["joinDate"] as? String ?? ""
                        let userInfo = UserInfo(firstname: firstname, lastname: lastname, joinedSince: joinDate)
                        
                        DispatchQueue.main.async {
                            completion(userInfo)
                        }
                    } else {
                        print("Failed to parse JSON")
                        completion(nil)
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion(nil)
                }
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
    
    
    func createURLMain() -> URL? {
        guard let encodedURL = URL(string: GlobalConstants.apiUrl + "/user")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            return nil
        }
        return url
    }
}

