//
//  AddListRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/30/21.
//

import Foundation

enum AddListError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case ListCreationFailed
}

struct AddListRequest {
    let requestURL:URLRequest
    
    init(listname:String) {
        let resourceString = "http://18.188.0.221:8080/list"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["name" : listname, "uuid": userUuid]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func addList (completion: @escaping(Result<AddListResponse, AddListError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let addListResponse = try decoder.decode(AddListResponse.self, from: jsonData)
                if (addListResponse.result) {
                    completion(.success(addListResponse))
                }
                else {
                    completion(.failure(.ListCreationFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
