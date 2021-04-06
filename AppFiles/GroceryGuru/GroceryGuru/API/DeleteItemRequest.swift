//
//  DeleteListRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/31/21.
//

import Foundation


enum DeleteItemError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case ListDeletionFailed
}

struct DeleteItemRequest {
    let requestURL:URLRequest
    
    init(item_id:Int) {
        let resourceString = "http://127.0.0.1:5000/item/delete"
        //TODO Revisit
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["item_id": item_id] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func deleteList (completion: @escaping(Result<DeleteListResponse, DeleteListError>) -> Void) {
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
                    completion(.failure(.ListDeletionFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
