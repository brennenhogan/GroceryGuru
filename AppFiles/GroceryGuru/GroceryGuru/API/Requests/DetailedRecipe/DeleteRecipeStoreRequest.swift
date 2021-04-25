//
//  DeleteStoreRequest.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/11/21.
//

import Foundation

enum DeleteRecipeStoreError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case IncorrectPermissions
}

struct DeleteRecipeStoreRequest {
    let requestURL:URLRequest
    
    init(store_id: Int, recipe_id: String) {
        let resourceString = "http://18.188.0.221:8080/recipe/store/delete"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["uuid" : userUuid, "recipe_id": recipe_id, "store_id": store_id] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func deleteRecipeStore (completion: @escaping(Result<BooleanResponse, DeleteRecipeStoreError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let deleteStoreResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (deleteStoreResponse.result) {
                    completion(.success(deleteStoreResponse))
                }
                else {
                    completion(.failure(.CanNotProcessData))
                }
            } catch{
                completion(.failure(.IncorrectPermissions))
            }
            
        }
        dataTask.resume()
    }
}
