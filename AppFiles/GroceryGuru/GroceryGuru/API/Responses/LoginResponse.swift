//
//  LoginResponse.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/23/21.
//

import Foundation


struct LoginResponse:Decodable {
    var result:Bool? = nil
    var message:String? = nil
    var uuid:String? = nil
}
