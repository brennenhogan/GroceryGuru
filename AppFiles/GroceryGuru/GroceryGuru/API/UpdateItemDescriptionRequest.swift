//
//  UpdateListRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/31/21.
//

import Foundation

enum UpdateItemDescriptionError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case ItemDescriptionUpdateFailed
}

struct UpdateItemDescriptionRequest {
    let requestURL:URLRequest
    
    init(item_description:String, item_id:Int) {
        let resourceString = "http://127.0.0.1:5000/item/description"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["description": item_description, "item_id": item_id] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func updateItemDescription (completion: @escaping(Result<DeleteListResponse, UpdateItemDescriptionError>) -> Void) {
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
                    completion(.failure(.ItemDescriptionUpdateFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}

