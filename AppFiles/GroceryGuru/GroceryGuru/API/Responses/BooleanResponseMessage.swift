//
//  BooleanResponse.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/31/21.
//

import Foundation

struct BooleanResponseMessage:Decodable {
    var result:Bool
    var message:String
}
