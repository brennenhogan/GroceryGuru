//
//  AllRecipeRequest.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/12/21.
//

import Foundation

enum AllRecipeError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case IncorrectPermissions
}

struct AllRecipeRequest {
    let requestURL:URLRequest
    
    init() {
        let resourceString = "http://18.188.0.221:8080/recipe/\(userUuid)"
        print(resourceString)
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "GET"
        self.requestURL = request
    }
    
    func getRecipe (completion: @escaping(Result<AllRecipeResponse, AllRecipeError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let recipeResponse = try decoder.decode(AllRecipeResponse.self, from: jsonData)
                completion(.success(recipeResponse))
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
