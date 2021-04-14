//
//  UpdateRecipeTitleRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/13/21.
//

import Foundation

enum UpdateRecipeTitleError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case RecipeTitleUpdateFailed
}

struct UpdateRecipeTitleRequest {
    let requestURL:URLRequest
    
    init(recipe_title:String, recipe_id:Int) {
        let resourceString = "http://127.0.0.1:5000/recipe/update"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["recipe_id": recipe_id, "name": recipe_title] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func updateRecipeTitle (completion: @escaping(Result<BooleanResponse, UpdateRecipeTitleError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let recipeUpdateResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (recipeUpdateResponse.result) {
                    completion(.success(recipeUpdateResponse))
                }
                else {
                    completion(.failure(.RecipeTitleUpdateFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
