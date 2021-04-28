//
//  AddRecipeRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/13/21.
//

import Foundation

enum AddRecipeRequestError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case RecipeAdditionFailed
}

struct AddRecipeRequest {
    let requestURL:URLRequest
    
    init(name: String) {
        let resourceString = "http://18.188.0.221:8080/recipe/create"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["uuid" : userUuid, "name": name]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func addRecipe (completion: @escaping(Result<BooleanResponseRecipeId, AddRecipeRequestError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let addRecipeResponse = try decoder.decode(BooleanResponseRecipeId.self, from: jsonData)
                if (addRecipeResponse.result) {
                    completion(.success(addRecipeResponse))
                }
                else {
                    completion(.failure(.RecipeAdditionFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
}
