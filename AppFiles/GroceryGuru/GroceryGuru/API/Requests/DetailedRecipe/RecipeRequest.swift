//
//  RecipeRequest.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/13/21.
//

import Foundation

enum RecipeError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case IncorrectPermissions
}

struct RecipeRequest {
    let requestURL:URLRequest
    
    init(recipe_id: String) {
        let resourceString = "http://127.0.0.1:5000/recipe/\(recipe_id)/\(userUuid)"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "GET"
        self.requestURL = request
    }
    
    func getRecipe (completion: @escaping(Result<RecipeResponse, RecipeError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let recipeResponse = try decoder.decode(RecipeResponse.self, from: jsonData)
                completion(.success(recipeResponse))
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
