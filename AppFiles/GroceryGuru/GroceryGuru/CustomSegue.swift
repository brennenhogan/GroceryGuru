//
//  CustomSegue.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/23/21.
//

import UIKit

class CustomSegue: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dst = self.destination
        src.navigationController?.pushViewController(dst, animated: true)
    }
}
