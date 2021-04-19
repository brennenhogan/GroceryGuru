//
//  CreateListFromRecipeRequest.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/14/21.
//

import Foundation

enum ImportRecipeError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case ImportRecipeRequestError
}

struct ImportRecipeRequest {
    let requestURL:URLRequest
    
    init(list_id:String, recipe_id:String) {
        let resourceString = "http://3.138.192.51:8080/list/recipeimport"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["recipe_id": recipe_id, "list_id": list_id] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func importRecipe (completion: @escaping(Result<BooleanResponse, ImportRecipeError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let importRecipeResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (importRecipeResponse.result) {
                    completion(.success(importRecipeResponse))
                }
                else {
                    completion(.failure(.ImportRecipeRequestError))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}


