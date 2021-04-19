//
//  DeleteStoreRequest.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/11/21.
//

import Foundation

enum DeleteStoreError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case IncorrectPermissions
}

struct DeleteStoreRequest {
    let requestURL:URLRequest
    
    init(store_id: String, list_id: String) {
        let resourceString = "http://18.188.0.221:8080/store/delete"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["uuid" : userUuid, "list_id": list_id, "store_id": store_id]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func deleteStore (completion: @escaping(Result<BooleanResponse, DeleteStoreError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let deleteStoreResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (deleteStoreResponse.result) {
                    completion(.success(deleteStoreResponse))
                }
                else {
                    completion(.failure(.CanNotProcessData))
                }
            } catch{
                completion(.failure(.IncorrectPermissions))
            }
            
        }
        dataTask.resume()
    }
}
