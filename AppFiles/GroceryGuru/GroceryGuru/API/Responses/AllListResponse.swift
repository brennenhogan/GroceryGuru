//
//  ListResponse.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/26/21.
//

import Foundation

struct AllListElement: Codable {
    let listID, listOld, listQty: Int
    var listName: String
    
    enum CodingKeys: String, CodingKey {
        case listID = "list_id"
        case listName = "list_name"
        case listOld = "list_old"
        case listQty = "list_qty"
    }
}

typealias AllListResponse = [AllListElement]
