//
//  UpdateCheckedRequest.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/14/21.
//

import Foundation

enum UpdateCheckedError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case ItemCheckedUpdateError
}

struct UpdateCheckedRequest {
    let requestURL:URLRequest
    
    init(item_id:Int, checked:Int) {
        let resourceString = "http://127.0.0.1:5000/recipe/check"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["item_id": item_id, "checked": checked] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func updateItemChecked (completion: @escaping(Result<BooleanResponse, UpdateCheckedError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let updateCheckedResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (updateCheckedResponse.result) {
                    completion(.success(updateCheckedResponse))
                }
                else {
                    completion(.failure(.ItemCheckedUpdateError))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}

