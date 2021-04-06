//
//  AddStoreRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/6/21.
//

import Foundation

enum AddStoreError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case StoreCreationFailed
}

struct AddStoreRequest {
    let requestURL:URLRequest
    
    init(storename:String) {
        let resourceString = "http://127.0.0.1:5000/store"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["store_name" : storename, "list_id": selected_list_id]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func addStore (completion: @escaping(Result<DeleteListResponse, AddStoreError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let deleteListResponse = try decoder.decode(DeleteListResponse.self, from: jsonData)
                if (deleteListResponse.result) {
                    completion(.success(deleteListResponse))
                }
                else {
                    completion(.failure(.StoreCreationFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
