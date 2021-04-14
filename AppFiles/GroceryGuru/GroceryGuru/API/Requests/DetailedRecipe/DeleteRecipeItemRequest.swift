//
//  DeleteItemRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/31/21.
//

import Foundation


enum DeleteRecipeItemError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case RecipeItemDeletionFailed
}

struct DeleteRecipeItemRequest {
    let requestURL:URLRequest
    
    init(item_id:Int) {
        let resourceString = "http://127.0.0.1:5000/recipeitem/delete"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["item_id": item_id] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func deleteRecipeItem (completion: @escaping(Result<BooleanResponse, DeleteRecipeItemError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let deleteItemResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (deleteItemResponse.result) {
                    completion(.success(deleteItemResponse))
                }
                else {
                    completion(.failure(.RecipeItemDeletionFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
