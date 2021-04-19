//
//  DeleteListRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/31/21.
//

import Foundation


enum DeleteListError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case ListDeletionFailed
}

struct DeleteListRequest {
    let requestURL:URLRequest
    
    init(list_id:Int) {
        let resourceString = "http://18.188.0.221:8080/list/delete"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["list_id": list_id, "uuid": userUuid] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func deleteList (completion: @escaping(Result<BooleanResponse, DeleteListError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let deleteListResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
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
