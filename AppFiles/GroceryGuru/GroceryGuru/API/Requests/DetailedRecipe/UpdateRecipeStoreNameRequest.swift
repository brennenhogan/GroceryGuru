//
//  UpdateStoreNameRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/11/21.
//

import Foundation

enum UpdateRecipeStoreNameError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case RecipeStoreNameUpdateFailed
}

struct UpdateRecipeStoreNameRequest {
    let requestURL:URLRequest
    
    init(store_name:String, store_id:String) {
        let resourceString = "http://3.138.192.51:8080/recipe/store/name"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["store_name": store_name, "store_id": store_id, "recipe_id": selected_recipe_id] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func updateRecipeStoreName (completion: @escaping(Result<BooleanResponse, UpdateRecipeStoreNameError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let updateRecipeStoreResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (updateRecipeStoreResponse.result) {
                    completion(.success(updateRecipeStoreResponse))
                }
                else {
                    completion(.failure(.RecipeStoreNameUpdateFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
