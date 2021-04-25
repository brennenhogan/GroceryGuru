//
//  OldListsBiggerCell.swift
//  GroceryGuru
//
//  Created by Mobile App on 4/21/21.
//

import UIKit

// Useful on the old lists page because the table view is slightly larger than the
// old list cell on the add new list view controller's table view
class OldListsBiggerCell: UITableViewCell {

    @IBOutlet weak var myText: UITextField!
    @IBOutlet var myQty: UILabel!
    
    static var identifier = "OldListsBiggerCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "OldListsBiggerCell", bundle: nil)
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
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
