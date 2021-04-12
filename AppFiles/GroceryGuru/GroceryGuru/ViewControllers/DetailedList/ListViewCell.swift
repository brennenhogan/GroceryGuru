//
//  ListViewCell.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/29/21.
//

import UIKit

protocol ItemDescriptionDelegate {
    func editDescription(item_id: Int, item_description: String)
}

protocol ItemQuantityDelegate {
    func editQty(item_id: Int, item_qty: String)
}

protocol CheckButtonDelegate {
    func markItem(item_id: Int, check: Int)
}

class ListViewCell: UITableViewCell {
    static var identifier = "ListViewCell"
    
    @IBOutlet var itemName: UITextField!
    @IBOutlet var itemQty: UITextField!
    @IBOutlet var checkBtn: UIButton!
    
    static func nib() -> UINib {
        return UINib(nibName: "ListViewCell", bundle: nil)
    }
    
    public func configure(title: String, qty: Int) {
        itemName.text = title
        itemQty.text = String(qty)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBtn.setImage(UIImage(systemName: "circle"), for: .normal)
        checkBtn.setImage(UIImage(systemName:"checkmark.circle.fill"), for: .selected)
    }
    
    func textFieldShouldReturn(_ itemName: UITextField) -> Bool {
        itemName.resignFirstResponder()
        return true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var itemQuantityDelegate: ItemQuantityDelegate?
    var itemDescriptionDelegate: ItemDescriptionDelegate?
    var checkButtonDelegate: CheckButtonDelegate?

    @IBAction func editDescription(_ sender: UITextField){
        let item_id = sender.tag
        itemDescriptionDelegate?.editDescription(item_id: item_id, item_description: sender.text!)
    }
    
    @IBAction func editQty(_ sender: UITextField){
        let item_id = sender.tag
        itemQuantityDelegate?.editQty(item_id: item_id, item_qty: sender.text!)
    }
    
    @IBAction func markItem(_ sender: UIButton){
        let item_id = sender.tag
        sender.isSelected = !sender.isSelected
        var result = 0
        
        if(sender.isSelected){
            result = 1
        }
        
        checkButtonDelegate?.markItem(item_id: item_id, check: result)
    }
    
}
