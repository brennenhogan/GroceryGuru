//
//  RecipeTableViewCell.swift
//  GroceryGuru
//
//  Created by Mobile App on 4/12/21.
//

import UIKit

class RecipeTableCell: UITableViewCell {
    
    @IBOutlet weak var myText: UITextField!
    @IBOutlet var myQty: UILabel!
    
    static var identifier = "RecipeTableCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "RecipeTableCell", bundle: nil)
    }
    
    public func configure(title: String, qty: Int) {
        myText.text = title
        myQty.text = String(qty)
        let sage = UIColor(hex: 0x94AA88)
        self.tintColor = sage
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme_grey = UIColor(hex: 0x636568)
        self.backgroundColor = theme_grey
        myText.returnKeyType = .done
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
        
}
