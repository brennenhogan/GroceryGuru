//
//  OldListsCell.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/7/21.
//

import UIKit

class OldListsCell: UITableViewCell {

    @IBOutlet weak var myText: UITextField!
    @IBOutlet var myQty: UILabel!
    
    static var identifier = "OldListsCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "OldListsCell", bundle: nil)
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
