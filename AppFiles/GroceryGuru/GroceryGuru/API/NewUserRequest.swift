//
//  NewUserRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/23/21.
//

import Foundation

enum NewUserError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case UserAlreadyExists
}

struct NewUserRequest {
    let requestURL:URLRequest
    
    init(username:String, password:String) {
        let resourceString = "http://127.0.0.1:5000/users"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["name" : username, "password": password]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func postNewUser (completion: @escaping(Result<NewUserResponse, NewUserError>) -> Void) {
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
                    completion(.failure(.UserAlreadyExists))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
