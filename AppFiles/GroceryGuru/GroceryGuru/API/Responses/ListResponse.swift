//
//  ListResponse.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/26/21.
//

import Foundation

struct ListResponse: Codable {
    var stores: [ListElement]
    let version: String
    
    init() {
        stores = [] // Initialize this as empty
        version = "1"
    }
}

struct ListElement: Codable {
    var items: [Item]
    var store_id: Int
    var name: String // name is the name of the store
}

struct Item : Codable {
    var itemDescription: String
    var itemID, listID, purchased, qty: Int
    
    enum CodingKeys: String, CodingKey {
        case itemDescription = "description"
        case itemID = "item_id"
        case listID = "list_id"
        case purchased, qty
    }
}
