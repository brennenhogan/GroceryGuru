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

class ListViewCell: UITableViewCell {
    static var identifier = "ListViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ListViewCell", bundle: nil)
    }
    
    public func configure(title: String, qty: Int) {
        itemName.text = title
        itemQty.text = String(qty)
    }

    @IBOutlet var itemName: UITextField!
    @IBOutlet var itemQty: UITextField!
    
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
    
    var itemQuantityDelegate: ItemQuantityDelegate?
    var itemDescriptionDelegate: ItemDescriptionDelegate?


    @IBAction func editDescription(_ sender: UITextField){
        let item_id = sender.tag
        itemDescriptionDelegate?.editDescription(item_id: item_id, item_description: sender.text!)
    }
    
    @IBAction func editQty(_ sender: UITextField){
        let item_id = sender.tag
        itemQuantityDelegate?.editQty(item_id: item_id, item_qty: sender.text!)
    }
    
}
