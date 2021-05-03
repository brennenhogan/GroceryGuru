//
//  RecipeCheckCell.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/14/21.
//

import UIKit

protocol CheckRecipeButtonDelegate {
    func markItem(item_id: Int, check: Int)
}

class RecipeCheckCell: UITableViewCell {

    static var identifier = "RecipeCheckCell"
    
    @IBOutlet var itemName: UITextField!
    @IBOutlet var itemQty: UITextField!
    @IBOutlet var checkBtn: UIButton!
    
    static func nib() -> UINib {
        return UINib(nibName: "RecipeCheckCell", bundle: nil)
    }
    
    public func configure(title: String, qty: Int) {
        itemName.text = title
        itemQty.text = String(qty)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBtn.setImage(UIImage(systemName: "circle"), for: .normal)
        checkBtn.setImage(UIImage(systemName:"xmark.circle.fill"), for: .selected)
    }
    
    func textFieldShouldReturn(_ itemName: UITextField) -> Bool {
        itemName.resignFirstResponder()
        return true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var checkButtonDelegate: CheckRecipeButtonDelegate?
    
    @IBAction func markItem(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        var result = 0
        
        if(sender.isSelected){
            result = 1
        }
        
        checkButtonDelegate?.markItem(item_id: sender.tag, check: result)
    }
}
