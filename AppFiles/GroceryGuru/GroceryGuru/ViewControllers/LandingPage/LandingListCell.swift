//
//  LandingListCell.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 3/29/21.
//

import UIKit

protocol TableViewCellDelegate {
    func textFieldDidEndEditing(cell: LandingListCell, name: String) -> ()
}

class LandingListCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: TableViewCellDelegate! = nil
    
    @IBOutlet weak var myText: UITextField!
    @IBOutlet var myQty: UILabel!
    
    static var identifier = "LandingListCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "LandingListCell", bundle: nil)
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
        myText.delegate = self
        myText.returnKeyType = .done
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(_ myText: UITextField) {
        self.delegate.textFieldDidEndEditing(cell: self, name: myText.text!)
    }
    
    func textFieldShouldReturn(_ myText: UITextField) -> Bool {
        myText.resignFirstResponder()
        return true
    }
    
}
