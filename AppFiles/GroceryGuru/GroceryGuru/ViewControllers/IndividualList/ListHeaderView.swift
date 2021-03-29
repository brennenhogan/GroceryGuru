//
//  ListHeaderCell.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/29/21.
//

import UIKit

class ListHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    
    static var identifier = "ListHeaderView"
    
    static func nib() -> UINib {
        return UINib(nibName: "ListHeaderView", bundle: nil)
    }
    
    public func configure(title: String) {
        titleLabel.text = title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
