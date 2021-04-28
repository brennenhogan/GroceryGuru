//
//  AddRecipeStoreRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/14/21.
//

import Foundation

enum AddRecipeStoreError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case StoreCreationFailed
}

struct AddRecipeStoreRequest {
    let requestURL:URLRequest
    
    init(storename:String) {
        let resourceString = "http://18.188.0.221:8080/recipe/store"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["store_name" : storename, "recipe_id": selected_recipe_id]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func addRecipeStore (completion: @escaping(Result<BooleanResponseStoreId, AddRecipeStoreError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let addRecipeStoreResponse = try decoder.decode(BooleanResponseStoreId.self, from: jsonData)
                if (addRecipeStoreResponse.result) {
                    completion(.success(addRecipeStoreResponse))
                }
                else {
                    completion(.failure(.StoreCreationFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
