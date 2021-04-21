//
//  ListViewCell.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/29/21.
//

import UIKit

protocol ItemDescriptionDelegate {
    func editDescription(item_id: Int, item_description: String, section: String, row: String)
}

protocol ItemQuantityDelegate {
    func editQty(item_id: Int, item_qty: String, section: String, row: String)
}

protocol CheckButtonDelegate {
    func markItem(item_id: Int, check: Int, section: String, row: String)
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
        let arr = sender.accessibilityLabel?.components(separatedBy: ",")
        itemDescriptionDelegate?.editDescription(item_id: Int(arr![2])!, item_description: sender.text!, section: arr![0], row: arr![1])
    }
    
    @IBAction func editQty(_ sender: UITextField){
        let arr = sender.accessibilityLabel?.components(separatedBy: ",")
        itemQuantityDelegate?.editQty(item_id: Int(arr![2])!, item_qty: sender.text!, section: arr![0], row: arr![1])
    }
    
    @IBAction func markItem(_ sender: UIButton){
        let arr = sender.accessibilityLabel?.components(separatedBy: ",")
        sender.isSelected = !sender.isSelected
        
        var result = 0
        if(sender.isSelected){
            result = 1
        }
        
        checkButtonDelegate?.markItem(item_id: Int(arr![2])!, check: result, section: arr![0], row: arr![1])
    }
    
}
