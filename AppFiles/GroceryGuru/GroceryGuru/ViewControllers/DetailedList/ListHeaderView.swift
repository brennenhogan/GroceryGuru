//
//  ListHeaderCell.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/29/21.
//

import UIKit

protocol EditStoreDelegate {
    func editStore(storeID: Int, store_name: String)
}

protocol AddItemDelegate {
    func addItem(storeID: Int)
}

protocol DeleteStoreDelegate {
    func deleteStore(storeID: Int)
}

protocol ExpandSectionDelegate {
    func expandSection(storeID: Int)
}

class ListHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var storeName: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var expandButton: UIButton!
    
    static var identifier = "ListHeaderView"
    
        
    var store_id: Int = 0
    
    static func nib() -> UINib {
        return UINib(nibName: "ListHeaderView", bundle: nil)
    }
    
    public func configure(title: String, storeID: Int) {
        storeName.text = title
        store_id = storeID
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        storeName.returnKeyType = .done
        expandButton.setImage(UIImage(systemName: "arrowtriangle.down"), for: .normal)
        expandButton.setImage(UIImage(systemName:"arrowtriangle.right"), for: .selected)
        storeName.delegate = self
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var addItemDelegate: AddItemDelegate?
    var deleteStoreDelegate: DeleteStoreDelegate?
    var editStoreDelegate: EditStoreDelegate?
    var expandSectionDelegate: ExpandSectionDelegate?
    
    @IBAction func editStore(_ sender: UITextField){
        editStoreDelegate?.editStore(storeID: store_id, store_name: storeName.text!)
    }

    @IBAction func addStore(_ sender: UIButton){
        addItemDelegate?.addItem(storeID: store_id)
    }
    
    @IBAction func deleteStore(_ sender: UIButton){
        deleteStoreDelegate?.deleteStore(storeID: store_id)
    }
    
    @IBAction func expandSection(_ sender: UIButton){
        sender.isSelected = !sender.isSelected

        expandSectionDelegate?.expandSection(storeID: store_id)
    }
}

extension ListHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ itemName: UITextField) -> Bool {
        storeName.resignFirstResponder() // dismiss keyboard
        return true
    }
}
