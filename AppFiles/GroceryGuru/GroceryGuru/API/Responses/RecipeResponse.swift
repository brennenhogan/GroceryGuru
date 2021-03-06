//
//  RecipeResponse.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/13/21.
//

import Foundation

struct RecipeElement: Codable {
    var items: [RecipeItem]
    var store_id: Int
    var name: String // name is the name of the store
}

struct RecipeItem : Codable {
    var itemDescription: String
    var itemID, recipeID, qty, checked: Int
    
    enum CodingKeys: String, CodingKey {
        case itemDescription = "description"
        case itemID = "item_id"
        case recipeID = "recipe_id"
        case qty
        case checked
    }
}

typealias RecipeResponse = [RecipeElement]
