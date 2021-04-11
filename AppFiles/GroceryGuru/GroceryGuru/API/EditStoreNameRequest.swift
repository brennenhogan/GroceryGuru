//
//  EditStoreNameRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/11/21.
//

import Foundation

enum EditStoreNameError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case StoreNameUpdateFailed
}

struct EditStoreNameRequest {
    let requestURL:URLRequest
    
    init(store_name:String, store_id:String, list_id:String) {
        let resourceString = "http://127.0.0.1:5000/store/description"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["store_name": store_name, "store_id": store_id, "list_id": list_id] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func editStoreName (completion: @escaping(Result<DeleteListResponse, EditStoreNameError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let editNameResponse = try decoder.decode(DeleteListResponse.self, from: jsonData)
                if (editNameResponse.result) {
                    completion(.success(editNameResponse))
                }
                else {
                    completion(.failure(.StoreNameUpdateFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
