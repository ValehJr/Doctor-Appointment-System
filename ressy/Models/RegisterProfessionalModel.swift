//
//  RegisterProfessionalModel.swift
//  ressy
//
//  Created by Valeh Ismayilov on 09.12.23.
//

import Foundation

struct Professional {
    var firstName:String
    var lastName:String
    var profession:String
    var email:String
    var password:String
}

class RegisterProfessionalModel {
    func validateUserInput(user: Professional, confirmPassword: String?) -> String? {
        guard !user.firstName.isEmpty else {
            return "Please enter your first name."
        }

        guard !user.lastName.isEmpty else {
            return "Please enter your last name."
        }

        guard !user.email.isEmpty else {
            return "Please enter your email."
        }
        
        guard !user.profession.isEmpty else {
            return "Please enter your field."
        }

        guard isValidEmail(email: user.email) else {
            return "Please enter a valid email address."
        }

        guard user.password.count >= 8 else {
            return "Password must be at least 8 characters."
        }

        guard user.password == confirmPassword else {
            return "Password and Confirm Password must be equal."
        }

        return nil
    }

    func registerUser(user: Professional, completion: @escaping (Bool) -> Void) {
        guard let url = createURL() else {
            completion(false)
            return
        }

        let parameters: [String: Any] = [
            "firstname": user.firstName,
            "lastname": user.lastName,
            "email": user.email,
            "profession":user.profession,
            "password": user.password
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            completion(false)
            return
        }

        let request = createURLRequest(url: url, jsonData: jsonData)

        performURLRequest(request) { success, errorMessage in
            if success {
                completion(success)
            } else {
                if let errorMessage = errorMessage {
                    print("Error: \(errorMessage)")
                }
            }
        }

    }

    private func performURLRequest(_ request: URLRequest, completion: @escaping (Bool, String?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(false, "Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid HTTP response")
                completion(false, "Invalid HTTP response")
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                completion(true, nil)
            } else {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Received data: \(responseString)")
                    completion(false, "Unsuccessful HTTP status code: \(httpResponse.statusCode)")
                } else {
                    print("Unsuccessful HTTP status code: \(httpResponse.statusCode)")
                    completion(false, "Unsuccessful HTTP status code: \(httpResponse.statusCode)")
                }
            }
        }

        task.resume()
    }


    private func createURL() -> URL? {
        guard let encodedURL = URL(string: GlobalConstants.apiUrl + "/auth/signup?type=doctor")?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            return nil
        }
        return url
    }

    private func createURLRequest(url: URL, jsonData: Data) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    func isValidEmail(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
