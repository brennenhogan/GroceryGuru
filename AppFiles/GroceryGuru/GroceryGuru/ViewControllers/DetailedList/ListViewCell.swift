//
//  ListViewCell.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/29/21.
//

import UIKit

protocol ListViewCellDelegate {
    func textFieldDidEndEditing(cell: ListViewCell, item_description: String) -> ()
}

class ListViewCell: UITableViewCell, UITextFieldDelegate {
    var delegate: ListViewCellDelegate! = nil
    
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
        itemName.delegate = self
        itemName.returnKeyType = .done
    }
    
    func textFieldDidEndEditing(_ itemName: UITextField) {
        self.delegate.textFieldDidEndEditing(cell: self, item_description: itemName.text!)
    }

    func textFieldShouldReturn(_ itemName: UITextField) -> Bool {
        itemName.resignFirstResponder()
        return true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
