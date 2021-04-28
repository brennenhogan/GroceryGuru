//
//  DetailedRecipeController.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/13/21.
//

import UIKit

class DetailedRecipeController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var recipeData = RecipeResponse() {
        didSet {
            DispatchQueue.main.async {
                print(String(self.recipeData.count) + " sections")
                if(!self.local){
                    print("Table reload with new data")
                    self.tableView.reloadData()
                } else{
                    self.local = false
                }
            }
        }
    }
    
    var hiddenSections = Set<Int>()
    var deleted = true
    var local = false
    var collapsing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = selected_recipe_name
        configureNavigationBar()
        
        tableView.register(RecipeViewCell.nib(), forCellReuseIdentifier:RecipeViewCell.identifier)
        tableView.register(RecipeHeaderView.nib(), forHeaderFooterViewReuseIdentifier:RecipeHeaderView.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getData()
    }
    
    private func getSection(store_id: Int) -> Int {
        for (index, store) in recipeData.enumerated(){
            if (store.store_id == store_id){
                return index
            }
        }
        return -1
    }
    
    private func configureNavigationBar() {
        // Nav Bar Colors
        let white = UIColor(hex: 0xFFFFFF)
        let dark_sage = UIColor(hex: 0x7A916E)
        
        // Sets Bar Tint and Tint Color
        self.navigationController?.navigationBar.barTintColor = white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = dark_sage
        
        // Sets the Title Color, Sizing, and Font
        let titleDict: NSDictionary = [
            NSAttributedString.Key.foregroundColor: dark_sage,
            NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 28)!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [NSAttributedString.Key : AnyObject]
        
        //For back button in navigation bar
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
    }
    
    func getData() {
        let recipeRequest = RecipeRequest(recipe_id: selected_recipe_id)
        recipeRequest.getRecipe { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error getting recipe data")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(let recipe):
                self?.recipeData = recipe
                print("Recipe data received properly")
            }
        }
    }
    
    func CreateAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
        alertController.view.tintColor = UIColor(hex: 0x7A916E)

        self.present(alertController, animated: true, completion: nil)
    }
        
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if (editingStyle == .delete){
            let item_id = recipeData[indexPath.section].items[indexPath.row].itemID

            let deleteRecipeRequest = DeleteRecipeItemRequest(item_id: item_id)
            deleteRecipeRequest.deleteRecipeItem { [weak self] result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.CreateAlert(title: "Error", message: "\(error)")
                        self?.deleted = false
                    }
                    print(error)
                case .success(let response):
                    print("Recipe has been deleted \(response)")
                    self?.deleted = response.result
                }
            }
            
            if(self.deleted){
                var items = recipeData[indexPath.section].items
                items.remove(at: indexPath.row)
                recipeData[indexPath.section].items = items
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.local = true
            }
            
            return
        }
    }
    
    @IBAction func addStore(_ sender: UIButton){
        let current_section_count = self.recipeData.count
        
        //Create recipe_id Action
        let addRecipeStoreRequest = AddRecipeStoreRequest(storename: "")
        addRecipeStoreRequest.addRecipeStore { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("Store has been created \(response.store_id)")
                self!.local = true
                
                let listElement = RecipeElement(items: [], store_id: response.store_id, name: "")
                self?.recipeData.append(listElement)
                DispatchQueue.main.async {
                    self?.tableView.insertSections([current_section_count], with: .automatic)
                    let header = (self?.tableView.headerView(forSection: current_section_count))! as! RecipeHeaderView
                    header.storeName.isEnabled = true
                    header.storeName.becomeFirstResponder() // Keyboard pop up on new item's description
                }
            }
        }
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem){
        self.tableView.isEditing = !self.tableView.isEditing
        sender.title = (self.tableView.isEditing) ? "Done" : "Edit"
                
        tableView.visibleCells.forEach{ cell in
            guard let cell = cell as? RecipeViewCell else { return }
            cell.itemName.isEnabled = tableView.isEditing
            cell.itemQty.isEnabled = tableView.isEditing
            cell.dash.isHidden = tableView.isEditing
            cell.itemName.borderStyle = (self.tableView.isEditing) ? .roundedRect : .none
            cell.itemQty.borderStyle = (self.tableView.isEditing) ? .roundedRect : .none
        }
        
        for i in 0...recipeData.count {
            guard let header = tableView.headerView(forSection: i) as? RecipeHeaderView else { return }
            header.deleteButton.isHidden = !tableView.isEditing
            header.storeName.isEnabled = tableView.isEditing
            header.addButton.isHidden = tableView.isEditing
            header.storeName.borderStyle = (self.tableView.isEditing) ? .roundedRect : .none
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension DetailedRecipeController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Unselect the tapped item
    }
}

extension DetailedRecipeController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return recipeData.count // The number of sections is the number of entries in the recipeData array
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35 // This is because the view is height 35 in the RecipeViewCell.xib
    }
    
    // Use custom header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: RecipeHeaderView.identifier) as! RecipeHeaderView
        view.configure(title: recipeData[section].name, storeID: recipeData[section].store_id)

        view.storeName.isEnabled = tableView.isEditing
        view.addButton.isHidden = tableView.isEditing
        view.deleteButton.isHidden = !tableView.isEditing
        
        view.updateRecipeStoreDelegate = self
        view.addRecipeItemDelegate = self
        view.deleteRecipeStoreDelegate = self
        view.expandRecipeSectionDelegate = self
        
        if(hiddenSections.contains(section)){
            view.expandButton.isSelected = true
        } else {
            view.expandButton.isSelected = false
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.hiddenSections.contains(section)){
            return 0
        } else{
            return recipeData[section].items.count // Set the number of sections to the number of items in that section
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = recipeData[indexPath.section].items[indexPath.row].itemDescription
        let qty = recipeData[indexPath.section].items[indexPath.row].qty
        let item_id = recipeData[indexPath.section].items[indexPath.row].itemID
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeViewCell.identifier, for: indexPath) as! RecipeViewCell
        
        cell.configure(title: text, qty: qty)
        cell.itemName.isEnabled = tableView.isEditing
        cell.itemQty.isEnabled = tableView.isEditing
        
        cell.itemName.tag = item_id
        cell.itemQty.tag = item_id
        
        cell.recipeItemQuantityDelegate = self
        cell.recipeItemDescriptionDelegate = self
                
        return cell
    }
}

extension DetailedRecipeController: ExpandRecipeSectionDelegate {
    func expandSection(storeID: Int) {
        let section = self.getSection(store_id: storeID)
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            
            for row in 0..<self.recipeData[section].items.count {
                indexPaths.append(IndexPath(row: row,
                                            section: section))
            }
            
            return indexPaths
        }
        
        if self.hiddenSections.contains(section) {
            self.hiddenSections.remove(section)
            self.tableView.insertRows(at: indexPathsForSection(),
                                      with: .fade)
        } else {
            self.collapsing = true // Indicates that a section has been collapsed
            self.tableView.endEditing(true)
            self.hiddenSections.insert(section)
            self.tableView.deleteRows(at: indexPathsForSection(),
                                      with: .fade)
        }
    }
}

extension DetailedRecipeController: DeleteRecipeStoreDelegate {
    func deleteRecipeStore(storeID: Int) {
        let section = self.getSection(store_id: storeID)
        print("deleting store: \(storeID)")
        
        let alert = UIAlertController(title: "Are you sure you want to delete \"\(recipeData[section].name)\" and all items in the section?", message: "", preferredStyle: .alert)

        alert.view.tintColor = UIColor(hex: 0x7A916E)
        self.present(alert, animated: true, completion: nil)
        
        // Grab the value from the text field when the user clicks Create
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { _ in
            
            let deleteRecipeStoreRequest = DeleteRecipeStoreRequest(store_id: storeID, recipe_id: selected_recipe_id)
            deleteRecipeStoreRequest.deleteRecipeStore { [weak self] result in
                switch result {
                case .failure(let error):
                    print("Error deleting store")
                    DispatchQueue.main.async {
                        self?.CreateAlert(title: "Error", message: "\(error)")
                    }
                    print(error)
                case .success(_):
                    print("Store deleted")
                    let indexSet = IndexSet(arrayLiteral: section)
                    DispatchQueue.main.async {
                        self!.recipeData.remove(at: section)
                        self!.tableView.deleteSections(indexSet, with: .automatic)
                    }
                    self!.local = true
                }
            }
        })
        deleteAction.isEnabled = true
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {(action: UIAlertAction!) -> Void in }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
    }
}

extension DetailedRecipeController: AddRecipeItemDelegate {
    func addRecipeItem(storeID: Int) {
        let section = self.getSection(store_id: storeID)
        let current_row_count = self.recipeData[section].items.count
        
        // Add Item Action
        let addRecipeItemRequest = AddRecipeItemRequest(description: "", store_id: storeID, qty: "1")
        
        addRecipeItemRequest.addRecipeItem { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("Item has been created \(response)")
                self!.local = true

                var items = self?.recipeData[section].items
                let item = RecipeItem(itemDescription: "", itemID: response.item_id, recipeID: Int(selected_recipe_id)!, qty: 1, checked: 0)
                items?.append(item)
                self?.recipeData[section].items = items!
                let indexPath = IndexPath(row: (current_row_count), section: section)

                DispatchQueue.main.async {
                    self?.tableView.insertRows(at: [indexPath], with: .automatic) // Insert new item
                    let cell = self?.tableView.cellForRow(at: indexPath) as! RecipeViewCell
                    cell.itemName.isEnabled = true
                    cell.itemName.becomeFirstResponder() // Keyboard pop up on new item's description
                }
            }
        }
    }
}

extension DetailedRecipeController: UpdateRecipeStoreDelegate {
    func updateRecipeStore(cell: RecipeHeaderView, storeID: Int, store_name: String) {
        let section = self.getSection(store_id: storeID)
        let updateRecipeStoreNameRequest = UpdateRecipeStoreNameRequest(store_name: store_name, store_id: storeID)
        updateRecipeStoreNameRequest.updateRecipeStoreName { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error editing store")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(_):
                print("Store edited")
                self!.recipeData[section].name = store_name
                self!.local = true
                DispatchQueue.main.async {
                    if(!self!.tableView.isEditing){ // If item is new, allow edit but set to false afterwards
                        cell.storeName.isEnabled = false
                    }
                }
            }
        }
    }
}

extension DetailedRecipeController: RecipeItemDescriptionDelegate {
    func updateRecipeItemDescription(cell: RecipeViewCell, item_id: Int, item_description: String) {
        let updateRecipeItemDescriptionRequest = UpdateRecipeItemDescriptionRequest(item_id: item_id, item_description: item_description)
        updateRecipeItemDescriptionRequest.updateRecipeItemDescription { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("Recipe has been updated \(response)")
                self!.local = true
                
                // Handles case where edit ends due to section collapse
                if(self!.collapsing){
                    self?.getData()
                    self!.collapsing = false
                } else {
                    DispatchQueue.main.async {
                        let indexPath = self!.tableView.indexPath(for: cell)!
                        self!.recipeData[indexPath.section].items[indexPath.row].itemDescription = item_description
                        
                        if(!self!.tableView.isEditing){ // If item is new, allow edit but set to false afterwards
                            cell.itemName.isEnabled = false
                        }
                    }
                }
            }
        }
        return
    }
}

extension DetailedRecipeController: RecipeItemQuantityDelegate {
    func updateRecipeItemQty(cell: RecipeViewCell, item_id: Int, item_qty: String) {
        let updateRecipeItemQuantityRequest = UpdateRecipeItemQuantityRequest(item_id: item_id, item_qty: item_qty)
        updateRecipeItemQuantityRequest.updateRecipeItemQty { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error editing item quantity")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(_):
                print("Quantity edited")
                self!.local = true
                
                // Handles case where edit ends due to section collapse
                if(self!.collapsing){
                    self?.getData()
                    self!.collapsing = false
                } else {
                    DispatchQueue.main.async {
                        let indexPath = self!.tableView.indexPath(for: cell)!
                        self!.recipeData[indexPath.section].items[indexPath.row].qty = Int(item_qty)!
                    }
                }
            }
        }
    }
}
