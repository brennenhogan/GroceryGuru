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
}

struct ResetPasswordRequest {
    let requestURL:URLRequest
    
    init(username:String, password:String) {
        let resourceString = "http://18.188.0.221:8080/resetpass"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["name" : username, "password": password]
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
                else {
                    completion(.failure(.UserDoesNotExist))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
