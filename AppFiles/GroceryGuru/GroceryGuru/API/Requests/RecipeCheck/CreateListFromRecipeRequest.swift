//
//  CreateListFromRecipeRequest.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/14/21.
//

import Foundation

enum CreateListFromRecipeError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case CreateListFromRecipeError
}

struct CreateListFromRecipeRequest {
    let requestURL:URLRequest
    
    init(name:String, recipe_id:String) {
        let resourceString = "http://3.138.192.51:8080/list/recipecreate"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["recipe_id": recipe_id, "name": name, "uuid": userUuid] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func createList (completion: @escaping(Result<AddListResponse, CreateListFromRecipeError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let createListFromRecipeResponse = try decoder.decode(AddListResponse.self, from: jsonData)
                if (createListFromRecipeResponse.result) {
                    completion(.success(createListFromRecipeResponse))
                }
                else {
                    completion(.failure(.CreateListFromRecipeError))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}


