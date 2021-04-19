//
//  DeleteStoreRequest.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/11/21.
//

import Foundation

enum DeleteRecipeError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case RecipeDeletionFailed
}

struct DeleteRecipeRequest {
    let requestURL:URLRequest
    
    init(recipe_id: String) {
        let resourceString = "http://18.188.0.221:8080/recipe/delete"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["recipe_id": recipe_id]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func deleteRecipe (completion: @escaping(Result<BooleanResponse, DeleteRecipeError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let deleteRecipeResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (deleteRecipeResponse.result) {
                    completion(.success(deleteRecipeResponse))
                }
                else {
                    completion(.failure(.CanNotProcessData))
                }
            } catch{
                completion(.failure(.RecipeDeletionFailed))
            }
            
        }
        dataTask.resume()
    }
}
