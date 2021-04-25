//
//  RecipeHeaderView.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/13/21.
//

import UIKit

/*
 protocol EditStoreDelegate {
     func editStore(storeID: String, store_name: String)
 }
*/
 protocol AddRecipeItemDelegate {
     func addRecipeItem(storeID: Int)
 }

 protocol DeleteRecipeStoreDelegate {
    func deleteRecipeStore(storeID: Int)
 }

 protocol ExpandRecipeSectionDelegate {
     func expandSection(storeID: Int)
 }

protocol UpdateRecipeStoreDelegate{
    func updateRecipeStore(storeID: Int, store_name: String)
}
 

class RecipeHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var storeName: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var expandButton: UIButton!
    
    static var identifier = "RecipeHeaderView"
        
    var store_id: Int = 0 // Temporary value that gets overwritten
    
    static func nib() -> UINib {
        return UINib(nibName: "RecipeHeaderView", bundle: nil)
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

    var expandRecipeSectionDelegate: ExpandRecipeSectionDelegate?
    var addRecipeItemDelegate: AddRecipeItemDelegate?
    var deleteRecipeStoreDelegate: DeleteRecipeStoreDelegate?
    var updateRecipeStoreDelegate: UpdateRecipeStoreDelegate?
    
    @IBAction func updateStore(_ sender: UITextField){
        updateRecipeStoreDelegate?.updateRecipeStore(storeID: store_id, store_name: storeName.text!)
    }

    @IBAction func addRecipeItem(_ sender: UIButton){
        addRecipeItemDelegate?.addRecipeItem(storeID: store_id)
    }
    
    @IBAction func deleteRecipeStore(_ sender: UIButton){
        deleteRecipeStoreDelegate?.deleteRecipeStore(storeID: store_id)
    }
    
    @IBAction func expandSection(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        
        expandRecipeSectionDelegate?.expandSection(storeID: store_id)
    }

}
