//
//  ShareListRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/19/21.
//

import Foundation

enum ShareListError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case UserDoesNotExist
    case UserAlreadyOwner
    case ShareListError
}

struct ShareListRequest {
    let requestURL:URLRequest
    
    init(name:String, list_id:Int) {
        let resourceString = "http://3.138.192.51:8080/share"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["name": name, "list_id": list_id] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func shareList (completion: @escaping(Result<BooleanResponseMessage, ShareListError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let shareListResponse = try decoder.decode(BooleanResponseMessage.self, from: jsonData)
                if (shareListResponse.result) {
                    completion(.success(shareListResponse))
                }
                else {
                    if (shareListResponse.message == "User does not exist"){
                        completion(.failure(.UserDoesNotExist))
                    } else if(shareListResponse.message == "User is already an owner") {
                        completion(.failure(.UserAlreadyOwner))
                    } else {
                        completion(.failure(.ShareListError))
                    }
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}

