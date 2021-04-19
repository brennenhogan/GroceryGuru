//
//  UpdateListRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/31/21.
//

import Foundation

enum UpdateListError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case ListUpdateFailed
}

struct UpdateListRequest {
    let requestURL:URLRequest
    
    init(name:String, list_id:Int) {
        let resourceString = "http://18.188.0.221:8080/list/update"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["name": name, "list_id": list_id] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func updateList (completion: @escaping(Result<BooleanResponse, UpdateListError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let updateListResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (updateListResponse.result) {
                    completion(.success(updateListResponse))
                }
                else {
                    completion(.failure(.ListUpdateFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}

