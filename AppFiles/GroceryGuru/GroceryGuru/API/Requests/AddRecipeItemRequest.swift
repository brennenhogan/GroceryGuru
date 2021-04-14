//
//  AddItemRequest.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/11/21.
//

import Foundation

enum AddRecipeItemRequestError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case ItemAdditionFailed
}

struct AddRecipeItemRequest {
    let requestURL:URLRequest
    
    init(description: String, store_id: String, qty: String) {
        let resourceString = "http://127.0.0.1:5000/recipe/add"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["store_id" : store_id, "recipe_id": selected_recipe_id, "qty": qty, "description": description]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func addRecipeItem (completion: @escaping(Result<BooleanResponse, AddRecipeItemRequestError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let addItemResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (addItemResponse.result) {
                    completion(.success(addItemResponse))
                }
                else {
                    completion(.failure(.ItemAdditionFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
}
