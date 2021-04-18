//
//  ImportRecipeCell.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/18/21.
//

import UIKit

class ImportRecipeCell: UITableViewCell {

    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet var recipeQty: UILabel!
    
    static var identifier = "ImportRecipeCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ImportRecipeCell", bundle: nil)
    }
    
    public func configure(title: String, qty: Int) {
        recipeName.text = title
        recipeQty.text = String(qty)
        let sage = UIColor(hex: 0x94AA88)
        self.tintColor = sage
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme_grey = UIColor(hex: 0x636568)
        self.backgroundColor = theme_grey
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
