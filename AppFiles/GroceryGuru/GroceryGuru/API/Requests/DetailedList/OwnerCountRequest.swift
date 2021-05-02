//
//  OwnerCountRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 5/2/21.
//

import Foundation

enum OwnerCountError:Error {
    case NoDataAvailable
    case CanNotProcessData
}

struct OwnerCountRequest {
    let requestURL:URLRequest
    
    init(list_id: String) {
        let resourceString = "http://18.188.0.221:8080/owner/count/\(list_id)"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "GET"
        self.requestURL = request
    }
    
    func getCount (completion: @escaping(Result<IntResponse, OwnerCountError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let listResponse = try decoder.decode(IntResponse.self, from: jsonData)
                completion(.success(listResponse))
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
