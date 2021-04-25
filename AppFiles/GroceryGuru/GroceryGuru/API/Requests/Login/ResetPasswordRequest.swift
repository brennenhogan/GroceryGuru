//
//  ResetPasswordRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/24/21.
//

import Foundation

enum ResetPasswordError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case UserDoesNotExist
    case OldPasswordIncorrect
}

struct ResetPasswordRequest {
    let requestURL:URLRequest
    
    init(username:String, old_password:String, new_password:String) {
        let resourceString = "http://18.188.0.221:8080/resetpass"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["name" : username, "old_password": old_password, "new_password": new_password]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "PUT"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func putPassword (completion: @escaping(Result<NewUserResponse, ResetPasswordError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let newUserResponse = try decoder.decode(NewUserResponse.self, from: jsonData)
                if (newUserResponse.uuid! != "") {
                    completion(.success(newUserResponse))
                }
                else if (newUserResponse.message == "ERROR: User does not exist") {
                    completion(.failure(.UserDoesNotExist))
                } else if (newUserResponse.message == "ERROR: Old password does not match") {
                    completion(.failure(.OldPasswordIncorrect))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
