//
//  ListHeaderCell.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/29/21.
//

import UIKit

protocol AddItemDelegate {
    func addItem(storeID: String)
}

class ListHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var storeName: UITextField!
    
    static var identifier = "ListHeaderView"
    
    var store_id: String = "0" // Temporary value that gets overwritten
    
    static func nib() -> UINib {
        return UINib(nibName: "ListHeaderView", bundle: nil)
    }
    
    public func configure(title: String, storeID: String) {
        storeName.text = title
        store_id = storeID
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
    
    var addItemDelegate: AddItemDelegate?
    
    @IBAction func addStore(_ sender: UIButton){
        print("In xib")
        addItemDelegate?.addItem(storeID: store_id)
    }

}
