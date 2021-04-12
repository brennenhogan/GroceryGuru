//
//  UpdatePurchasedRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/12/21.
//

import Foundation

enum UpdatePurchasedError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case ItemPurchasedUpdateError
}

struct UpdatePurchasedRequest {
    let requestURL:URLRequest
    
    init(item_id:Int, purchased:Int) {
        let resourceString = "http://127.0.0.1:5000/item/check"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["item_id": item_id, "purchased": purchased] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func updateItemPurchased (completion: @escaping(Result<DeleteListResponse, UpdatePurchasedError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let updatePurchasedResponse = try decoder.decode(DeleteListResponse.self, from: jsonData)
                if (updatePurchasedResponse.result) {
                    completion(.success(updatePurchasedResponse))
                }
                else {
                    completion(.failure(.ItemPurchasedUpdateError))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}

