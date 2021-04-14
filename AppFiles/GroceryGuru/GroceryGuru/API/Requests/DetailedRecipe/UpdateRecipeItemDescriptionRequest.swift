//
//  UpdateListRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/31/21.
//

import Foundation

enum UpdateRecipeItemDescriptionError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case RecipeItemDescriptionUpdateFailed
}

struct UpdateRecipeItemDescriptionRequest {
    let requestURL:URLRequest
    
    init(item_id:Int, item_description:String) {
        let resourceString = "http://127.0.0.1:5000/recipe/item/description"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["item_description": item_description, "item_id": item_id] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func updateRecipeItemDescription (completion: @escaping(Result<BooleanResponse, UpdateRecipeItemDescriptionError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let updateRecipeItemDescriptionResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (updateRecipeItemDescriptionResponse.result) {
                    completion(.success(updateRecipeItemDescriptionResponse))
                }
                else {
                    completion(.failure(.RecipeItemDescriptionUpdateFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}

