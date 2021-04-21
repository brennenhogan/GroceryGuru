//
//  RecipeViewCell.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/13/21.
//

import UIKit

protocol RecipeItemDescriptionDelegate {
    func updateRecipeItemDescription(item_id: Int, item_description: String, section: Int, row: Int)
}

protocol RecipeItemQuantityDelegate {
    func updateRecipeItemQty(item_id: Int, item_qty: String, section: Int, row: Int)
}

class RecipeViewCell: UITableViewCell {

    static var identifier = "RecipeViewCell"
    
    @IBOutlet var itemName: UITextField!
    @IBOutlet var itemQty: UITextField!
    
    static func nib() -> UINib {
        return UINib(nibName: "RecipeViewCell", bundle: nil)
    }
    
    public func configure(title: String, qty: Int) {
        itemName.text = title
        itemQty.text = String(qty)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func textFieldShouldReturn(_ itemName: UITextField) -> Bool {
        itemName.resignFirstResponder()
        return true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var recipeItemDescriptionDelegate: RecipeItemDescriptionDelegate?
    var recipeItemQuantityDelegate: RecipeItemQuantityDelegate?
    
    @IBAction func updateRecipeItemDescription(_ sender: UITextField){
        let arr = sender.accessibilityLabel?.components(separatedBy: ",")
        recipeItemDescriptionDelegate?.updateRecipeItemDescription(item_id: Int(arr![2])!, item_description: sender.text!, section: Int(arr![0])!, row: Int(arr![1])!)
    }
    
    @IBAction func updateRecipeItemQty(_ sender: UITextField){
        let arr = sender.accessibilityLabel?.components(separatedBy: ",")
        recipeItemQuantityDelegate?.updateRecipeItemQty(item_id: Int(arr![2])!, item_qty: sender.text!, section: Int(arr![0])!, row: Int(arr![1])!)
    }
}
