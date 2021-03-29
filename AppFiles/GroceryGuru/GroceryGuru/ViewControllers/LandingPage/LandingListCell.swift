//
//  LandingListCell.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/29/21.
//

import UIKit

class LandingListCell: UITableViewCell {
    static var identifier = "LandingListCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "LandingListCell", bundle: nil)
    }
    
    public func configure(title: String, qty: Int) {
        myLabel.text = title
        myQty.text = String(qty)
    }

    @IBOutlet var myLabel: UILabel!
    @IBOutlet var myQty: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
