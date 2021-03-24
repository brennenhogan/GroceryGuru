//
//  LoginRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/23/21.
//

import Foundation

enum LoginError:Error {
    case noDataAvailable
    case canNotProcessData
}

struct LoginRequest {
    let requestURL:URLRequest
    
    init(username:String, password:String) {
        let resourceString = "http://127.0.0.1:5000/login"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["name" : username, "password": password]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func postLogin (completion: @escaping(Result<LoginResponse, LoginError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let loginResponse = try decoder.decode(LoginResponse.self, from: jsonData)
                completion(.success(loginResponse))
            } catch{
                completion(.failure(.canNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
