//
//  BooleanResponseVersion.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/20/21.
//

import Foundation

struct BooleanResponseVersion:Decodable {
    var version:Int
    var result:Bool
}
