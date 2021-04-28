//
//  RecipeViewCell.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/13/21.
//

import UIKit

protocol RecipeItemDescriptionDelegate {
    func updateRecipeItemDescription(cell: RecipeViewCell, item_id: Int, item_description: String)
}

protocol RecipeItemQuantityDelegate {
    func updateRecipeItemQty(cell: RecipeViewCell, item_id: Int, item_qty: String)
}

class RecipeViewCell: UITableViewCell {

    static var identifier = "RecipeViewCell"
    
    @IBOutlet var itemName: UITextField!
    @IBOutlet var itemQty: UITextField!
    @IBOutlet var dash: UIButton!
    
    static func nib() -> UINib {
        return UINib(nibName: "RecipeViewCell", bundle: nil)
    }
    
    public func configure(title: String, qty: Int) {
        itemName.text = title
        itemQty.text = String(qty)
        itemName.delegate = self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var recipeItemDescriptionDelegate: RecipeItemDescriptionDelegate?
    var recipeItemQuantityDelegate: RecipeItemQuantityDelegate?
    
    @IBAction func updateRecipeItemDescription(_ sender: UITextField){
        recipeItemDescriptionDelegate?.updateRecipeItemDescription(cell: self, item_id: sender.tag, item_description: sender.text!)
    }
    
    @IBAction func updateRecipeItemQty(_ sender: UITextField){
        recipeItemQuantityDelegate?.updateRecipeItemQty(cell: self, item_id: sender.tag, item_qty: sender.text!)
    }
}

extension RecipeViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ itemName: UITextField) -> Bool {
        itemName.resignFirstResponder() // dismiss keyboard
        return true
    }
}
