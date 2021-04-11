//
//  AddItemRequest.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/11/21.
//

import Foundation

enum AddItemRequestError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case ItemAdditionFailed
}

struct AddItemRequest {
    let requestURL:URLRequest
    
    init(description: String, list_id: String, store_id: String, qty: String) {
        let resourceString = "http://127.0.0.1:5000/item"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["store_id" : store_id, "list_id": list_id, "qty": qty, "description": description]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func addItem (completion: @escaping(Result<DeleteListResponse, AddItemRequestError>) -> Void) {
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
                    completion(.failure(.ItemAdditionFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
}
