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
    
    init(description: String, list_id: String, store_id: Int, qty: String) {
        let resourceString = "http://18.188.0.221:8080/item"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["store_id" : store_id, "list_id": list_id, "qty": qty, "description": description] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func addItem (completion: @escaping(Result<BooleanResponseItemId, AddItemRequestError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let addItemResponse = try decoder.decode(BooleanResponseItemId.self, from: jsonData)
                if (addItemResponse.result) {
                    completion(.success(addItemResponse))
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
