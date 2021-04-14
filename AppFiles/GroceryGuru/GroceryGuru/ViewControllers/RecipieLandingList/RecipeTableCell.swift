//
//  RecipeTableViewCell.swift
//  GroceryGuru
//
//  Created by Mobile App on 4/12/21.
//

import UIKit

protocol RecipeTitleDelegate {
    func editTitle(recipe_id: Int, recipe_title: String)
}

class RecipeTableCell: UITableViewCell {
    
    @IBOutlet weak var recipeTitle: UITextField!
    @IBOutlet weak var recipeQty: UITextField!
    
    static var identifier = "RecipeTableCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "RecipeTableCell", bundle: nil)
    }
    
    public func configure(title: String, qty: Int) {
        recipeTitle.text = title
        recipeQty.text = String(qty)
        let sage = UIColor(hex: 0x94AA88)
        self.tintColor = sage
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme_grey = UIColor(hex: 0x636568)
        self.backgroundColor = theme_grey
        recipeTitle.returnKeyType = .done
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(_ myText: UITextField) -> Bool {
        myText.resignFirstResponder()
        return true
    }
    
    var recipeTitleDelegate: RecipeTitleDelegate?
    
    @IBAction func editTitle(_ sender: UITextField){
        recipeTitleDelegate?.editTitle(recipe_id: sender.tag, recipe_title: sender.text!)
    }
        
}
