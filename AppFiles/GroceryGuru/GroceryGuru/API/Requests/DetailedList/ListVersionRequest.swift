//
//  ListVersionRequest.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/20/21.
//

import Foundation

enum ListVersionError:Error {
    case NoDataAvailable
    case CanNotProcessData
    case IncorrectPermissions
}

struct ListVersionRequest {
    let requestURL:URLRequest
    
    init(list_id: String) {
        let resourceString = "http://18.188.0.221:8080/list/\(list_id)/\(userUuid)/version"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "GET"
        self.requestURL = request
    }
    
    func getVersion (completion: @escaping(Result<BooleanResponseVersion, ListVersionError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: requestURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(.NoDataAvailable))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let versionResponse = try decoder.decode(BooleanResponseVersion.self, from: jsonData)
                completion(.success(versionResponse))
            } catch{
                completion(.failure(.CanNotProcessData))
            }
            
        }
        dataTask.resume()
    }
    
}
