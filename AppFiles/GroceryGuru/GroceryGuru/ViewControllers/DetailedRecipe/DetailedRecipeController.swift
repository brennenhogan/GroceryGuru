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
                print("Table reload with new data")
                print(String(self.recipeData.count) + " sections")
                self.tableView.reloadData()
            }
        }
    }
    
    var hiddenSections = Set<Int>()
    
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

            let deleteRequest = DeleteItemRequest(item_id: item_id)
            deleteRequest.deleteItem { [weak self] result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.CreateAlert(title: "Error", message: "\(error)")
                        deleted = false
                    }
                    print(error)
                case .success(let response):
                    print("Recipe has been deleted \(response)")
                    deleted = response.result
                }
            }
            
            if(deleted){
                var items = recipeData[indexPath.section].items
                items.remove(at: indexPath.row)
                recipeData[indexPath.section].items = items
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            return
        }
    }
    
    @IBAction func addStore(_ sender: UIButton){
        let alert = UIAlertController(title: "Enter a Store Name", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.view.tintColor = UIColor(hex: 0x7A916E)
        self.present(alert, animated: true, completion: nil)
        
        // Grab the value from the text field when the user clicks Create
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            //Create recipe_id Action
            let addStoreRequest = AddStoreRequest(storename: (textField?.text)!)
            addStoreRequest.addStore { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let response):
                    print("Store has been created \(response)")
                    self?.getData()
                }
            }
        })
        
        createAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {(action: UIAlertAction!) -> Void in }
        
        // adding the notification observer here
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:alert.textFields?[0], queue: OperationQueue.main) { (notification) -> Void in
            let textFieldName = (alert.textFields?[0])! as UITextField
            createAction.isEnabled = !textFieldName.text!.isEmpty
            }
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
        
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem){
        self.tableView.isEditing = !self.tableView.isEditing
        sender.title = (self.tableView.isEditing) ? "Done" : "Edit"
                
        tableView.visibleCells.forEach{ cell in
            guard let cell = cell as? RecipeViewCell else { return }
            cell.itemName.isEnabled = tableView.isEditing
            cell.itemQty.isEnabled = tableView.isEditing
        }
        
        for i in 0...recipeData.count {
            guard let header = tableView.headerView(forSection: i) as? RecipeHeaderView else { return }
            header.deleteButton.isHidden = !tableView.isEditing
            header.storeName.isEnabled = tableView.isEditing
            header.addButton.isHidden = tableView.isEditing
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension DetailedRecipeController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped cell!!")
    }
    
}

extension DetailedRecipeController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return recipeData.count // The number of sections is the number of entries in the recipeData array
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 // This is because the view is height 50 in the RecipeViewCell.xib
    }
    
    // Use custom header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: RecipeHeaderView.identifier) as! RecipeHeaderView
        view.configure(title: recipeData[section].name, storeID: String(recipeData[section].store_id)) // TODO - add buttons here that do things

        view.storeName.isEnabled = tableView.isEditing
        view.addButton.isHidden = tableView.isEditing
        view.deleteButton.isHidden = !tableView.isEditing
        view.expandButton.tag = section
        
        /*view.addItemDelegate = self // Be listening for the button tap in the header
        view.deleteStoreDelegate = self
        view.editStoreDelegate = self*/
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
        //cell.checkBtn.isSelected = (purchased == 1)
        cell.itemName.tag = item_id
        cell.itemQty.tag = item_id
        
        /*cell.itemQuantityDelegate = self
        cell.itemDescriptionDelegate = self
        cell.checkButtonDelegate = self*/
                
        return cell
    }
}

extension DetailedRecipeController: AddItemDelegate {
    func addItem(storeID: String) {
        print("In Delegate")
        let alert = UIAlertController(title: "Enter an Item Name", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.view.tintColor = UIColor(hex: 0x7A916E)
        self.present(alert, animated: true, completion: nil)
        
        // Grab the value from the text field when the user clicks Add
        let createAction = UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            // Add Item Action
            let addItemRequest = AddItemRequest(description: (textField?.text)!, list_id: selected_recipe_id, store_id: storeID, qty: "1")
            
            addItemRequest.addItem { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let response):
                    print("Item has been created \(response)")
                    self?.getData()
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {(action: UIAlertAction!) -> Void in }
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
    }
}

extension DetailedRecipeController: DeleteStoreDelegate {
    func deleteStore(storeID: String, section: Int) {
        print("deleting store: " + storeID)
        let deleteStoreRequest = DeleteStoreRequest(store_id: storeID, list_id: selected_recipe_id)
        deleteStoreRequest.deleteStore { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error deleting store")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(_):
                print("Store deleted")
                self?.getData()
            }
        }
    }
}

extension DetailedRecipeController: EditStoreDelegate {
    func editStore(storeID: String, store_name: String) {
        let updateStoreNameRequest = UpdateStoreNameRequest(store_name: store_name, store_id: storeID, list_id: selected_recipe_id)
        updateStoreNameRequest.updateStoreName { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error editing store")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(_):
                print("Store edited")
                self?.getData()
            }
        }
    }
}

extension DetailedRecipeController: ItemQuantityDelegate {
    func editQty(item_id: Int, item_qty: String) {
        let updateStoreNameRequest = UpdateItemQuantityRequest(item_id: item_id, item_qty: item_qty)
        updateStoreNameRequest.updateStoreName { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error editing item quantity")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(_):
                print("Quantity edited")
                self?.getData()
            }
        }
    }
}

extension DetailedRecipeController: ItemDescriptionDelegate {
    func editDescription(item_id: Int, item_description: String) {
        let updateItemDescriptionRequest = UpdateItemDescriptionRequest(item_id: item_id, item_description: item_description)
        updateItemDescriptionRequest.updateItemDescription { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("Recipe has been updated \(response)")
                self?.getData()
            }
        }
        return
    }
}

extension DetailedRecipeController: ExpandRecipeSectionDelegate {
    func expandSection(section: Int) {
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
            self.hiddenSections.insert(section)
            self.tableView.deleteRows(at: indexPathsForSection(),
                                      with: .fade)
        }
    }
}

