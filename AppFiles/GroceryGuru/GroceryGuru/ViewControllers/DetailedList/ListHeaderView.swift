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

protocol DeleteStoreDelegate {
    func deleteStore(storeID: String)
}

class ListHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var storeName: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    
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
    var deleteStoreDelegate: DeleteStoreDelegate?
    
    @IBAction func addStore(_ sender: UIButton){
        addItemDelegate?.addItem(storeID: store_id)
    }
    
    @IBAction func deleteStore(_ sender: UIButton){
        deleteStoreDelegate?.deleteStore(storeID: store_id)
    }

}
