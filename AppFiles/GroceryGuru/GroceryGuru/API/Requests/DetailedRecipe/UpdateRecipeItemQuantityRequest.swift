//
//  UpdateItemQuantityRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/11/21.
//

import Foundation

enum UpdateRecipeItemQuantityError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case RecipeItemQuantityUpdateFailed
}

struct UpdateRecipeItemQuantityRequest {
    let requestURL:URLRequest
    
    init(item_id:Int, item_qty:String) {
        let resourceString = "http://18.188.0.221:8080/recipe/item/qty"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        let parameterDictionary = ["item_id": item_id, "item_qty": item_qty] as [String : Any]
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {fatalError()}
        request.httpBody = httpBody
        self.requestURL = request
    }
    
    func updateRecipeItemQty (completion: @escaping(Result<BooleanResponse, UpdateRecipeItemQuantityError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let editQtyResponse = try decoder.decode(BooleanResponse.self, from: jsonData)
                if (editQtyResponse.result) {
                    completion(.success(editQtyResponse))
                }
                else {
                    completion(.failure(.RecipeItemQuantityUpdateFailed))
                }
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
