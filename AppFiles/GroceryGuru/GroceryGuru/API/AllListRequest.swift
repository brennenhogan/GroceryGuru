//
//  ListRequest.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/26/21.
//

import Foundation

enum AllListError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case IncorrectPermissions
}

struct AllListRequest {
    let requestURL:URLRequest
    
    init() {
        let resourceString = "http://127.0.0.1:5000/owner/\(userUuid)"
        print(resourceString)
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "GET"
        self.requestURL = request
    }
    
    func getList (completion: @escaping(Result<AllListResponse, AllListError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let listResponse = try decoder.decode(AllListResponse.self, from: jsonData)
                completion(.success(listResponse))
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
