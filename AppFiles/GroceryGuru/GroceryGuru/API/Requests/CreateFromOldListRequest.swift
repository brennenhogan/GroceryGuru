//
//  CreatFromOldListRequest.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/7/21.
//

import Foundation

enum CreatFromOldListRequestError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case ListCreationFailed
}

struct CreatFromOldListRequest {
    let requestURL:URLRequest
    
    init(name: String, list_id: String) {
        let resourceString = "http://127.0.0.1:5000/list/old"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["name" : name, "list_id": list_id, "uuid": userUuid]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func createList (completion: @escaping(Result<AddListResponse, CreatFromOldListRequestError>) -> Void) {
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
