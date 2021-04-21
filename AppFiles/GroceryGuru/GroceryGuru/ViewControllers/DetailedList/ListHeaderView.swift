//
//  ListHeaderCell.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/29/21.
//

import UIKit

protocol EditStoreDelegate {
    func editStore(storeID: String, store_name: String, section: Int)
}

protocol AddItemDelegate {
    func addItem(storeID: String)
}

protocol DeleteStoreDelegate {
    func deleteStore(storeID: String, section: Int)
}

protocol ExpandSectionDelegate {
    func expandSection(section: Int)
}

class ListHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var storeName: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var expandButton: UIButton!
    
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
        storeName.returnKeyType = .done
        expandButton.setImage(UIImage(systemName: "arrowtriangle.down"), for: .normal)
        expandButton.setImage(UIImage(systemName:"arrowtriangle.right"), for: .selected)
    }

    func textFieldShouldReturn(_ itemName: UITextField) -> Bool {
        itemName.resignFirstResponder()
        return true
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
        editStoreDelegate?.editStore(storeID: store_id, store_name: storeName.text!, section: sender.tag)
    }

    @IBAction func addStore(_ sender: UIButton){
        addItemDelegate?.addItem(storeID: store_id)
    }
    
    @IBAction func deleteStore(_ sender: UIButton){
        let section = sender.tag
        deleteStoreDelegate?.deleteStore(storeID: store_id, section: section)
    }
    
    @IBAction func expandSection(_ sender: UIButton){
        let section = sender.tag
        sender.isSelected = !sender.isSelected

        expandSectionDelegate?.expandSection(section: section)
    }

}
