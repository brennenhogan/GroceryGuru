//
//  AllRecipeResponse.swift
//  GroceryGuru
//
//  Created by BrendanSailer on 4/12/21.
//

import Foundation

struct AllRecipeElement: Codable {
    let recipeID: Int
    let recipeQty: Int
    var recipeName: String
    
    enum CodingKeys: String, CodingKey {
        case recipeID = "recipe_id"
        case recipeName = "name"
        case recipeQty = "recipe_qty"
    }
}

typealias AllRecipeResponse = [AllRecipeElement]
