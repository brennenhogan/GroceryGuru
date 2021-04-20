//
//  DetailedListController.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/26/21.
//

import UIKit

public var filter_selection = 0

class DetailedListController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var listData = ListResponse() {
        didSet {
            DispatchQueue.main.async {
                print("Table reload with new data")
                print(String(self.listData.stores.count) + " sections")
                self.tableView.reloadData()
            }
        }
    }
    
    var hiddenSections = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = selected_list_name
        configureNavigationBar()
        
        tableView.register(ListViewCell.nib(), forCellReuseIdentifier:ListViewCell.identifier)
        tableView.register(ListHeaderView.nib(), forHeaderFooterViewReuseIdentifier:ListHeaderView.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.getData()
        
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
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
        let listRequest = ListRequest(list_id: selected_list_id, filter: filter_selection)
        listRequest.getList { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error getting data")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(let list):
                self?.listData = list
                print("Data received properly")
            }
        }
    }
    
    func CreateAlert(title: String, message: String) {

            let alertController = UIAlertController(title: title, message:
                                                        message, preferredStyle: UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
        alertController.view.tintColor = UIColor(hex: 0x7A916E)

            self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToDetail(_ segue: UIStoryboardSegue) {}
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if (editingStyle == .delete){
            let item_id = listData.stores[indexPath.section].items[indexPath.row].itemID

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
                    print("List has been deleted \(response)")
                    deleted = response.result
                }
            }
            
            if(deleted){
                var items = listData.stores[indexPath.section].items
                items.remove(at: indexPath.row)
                listData.stores[indexPath.section].items = items
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
            //Create List Action
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
            guard let cell = cell as? ListViewCell else { return }
            cell.itemName.isEnabled = tableView.isEditing
            cell.itemQty.isEnabled = tableView.isEditing
            cell.checkBtn.isHidden = tableView.isEditing
        }
        
        for i in 0...listData.stores.count {
            guard let header = tableView.headerView(forSection: i) as? ListHeaderView else { return }
            header.deleteButton.isHidden = !tableView.isEditing
            header.storeName.isEnabled = tableView.isEditing
            header.addButton.isHidden = tableView.isEditing
        }
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        filter_selection = sender.selectedSegmentIndex
        self.getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension DetailedListController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped cell!!")
    }
    
}

extension DetailedListController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listData.stores.count // The number of sections is the number of entries in the listData array
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 // This is because the view is height 50 in the ListViewCell.xib
    }
    
    // Use custom header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ListHeaderView.identifier) as! ListHeaderView
        view.configure(title: listData.stores[section].name, storeID: String(listData.stores[section].store_id)) // TODO - add buttons here that do things

        view.storeName.isEnabled = tableView.isEditing
        view.addButton.isHidden = tableView.isEditing
        view.deleteButton.isHidden = !tableView.isEditing
        view.deleteButton.tag = section
        view.expandButton.tag = section
        
        view.addItemDelegate = self // Be listening for the button tap in the header
        view.deleteStoreDelegate = self
        view.editStoreDelegate = self
        view.expandSectionDelegate = self
        
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
            return listData.stores[section].items.count // Set the number of sections to the number of items in that section
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = listData.stores[indexPath.section].items[indexPath.row].itemDescription
        let qty = listData.stores[indexPath.section].items[indexPath.row].qty
        let item_id = listData.stores[indexPath.section].items[indexPath.row].itemID
        let purchased = listData.stores[indexPath.section].items[indexPath.row].purchased
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ListViewCell.identifier, for: indexPath) as! ListViewCell
        
        cell.configure(title: text, qty: qty)
        cell.itemName.isEnabled = tableView.isEditing
        cell.itemQty.isEnabled = tableView.isEditing
        cell.checkBtn.isHidden = tableView.isEditing
        cell.checkBtn.isSelected = (purchased == 1)
        cell.itemName.tag = item_id
        cell.itemQty.tag = item_id
        cell.checkBtn.tag = item_id
        cell.itemQuantityDelegate = self
        cell.itemDescriptionDelegate = self
        cell.checkButtonDelegate = self
                
        return cell
    }
}

extension DetailedListController: AddItemDelegate {
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
            let addItemRequest = AddItemRequest(description: (textField?.text)!, list_id: selected_list_id, store_id: storeID, qty: "1")
            
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
        
        // adding the notification observer here
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:alert.textFields?[0], queue: OperationQueue.main) { (notification) -> Void in
            let textFieldName = (alert.textFields?[0])! as UITextField
            createAction.isEnabled = !textFieldName.text!.isEmpty
            }
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
    }
}

extension DetailedListController: DeleteStoreDelegate {
    func deleteStore(storeID: String, section: Int) {
        print("deleting store: " + storeID)
        let alert = UIAlertController(title: "Are you sure you want to delete \"\(listData.stores[section].name)\" and all items in the section?", message: "", preferredStyle: .alert)

        alert.view.tintColor = UIColor(hex: 0x7A916E)
        self.present(alert, animated: true, completion: nil)
        
        // Grab the value from the text field when the user clicks Create
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { _ in
            //Create List Action
            let deleteStoreRequest = DeleteStoreRequest(store_id: storeID, list_id: selected_list_id)
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
        })
        
        deleteAction.isEnabled = true
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {(action: UIAlertAction!) -> Void in }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
    }
}

extension DetailedListController: EditStoreDelegate {
    func editStore(storeID: String, store_name: String) {
        let updateStoreNameRequest = UpdateStoreNameRequest(store_name: store_name, store_id: storeID, list_id: selected_list_id)
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

extension DetailedListController: ItemQuantityDelegate {
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

extension DetailedListController: ItemDescriptionDelegate {
    func editDescription(item_id: Int, item_description: String) {
        let updateItemDescriptionRequest = UpdateItemDescriptionRequest(item_id: item_id, item_description: item_description)
        updateItemDescriptionRequest.updateItemDescription { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("List has been updated \(response)")
                self?.getData()
            }
        }
        return
    }
}

extension DetailedListController: ExpandSectionDelegate {
    func expandSection(section: Int) {
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            
            for row in 0..<self.listData.stores[section].items.count {
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

extension DetailedListController: CheckButtonDelegate {
    func markItem(item_id: Int, check: Int) {
        let updatePurchasedRequest = UpdatePurchasedRequest(item_id: item_id, purchased: check)
        updatePurchasedRequest.updateItemPurchased { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("Item purchased has been updated \(response)")
                self?.getData()
            }
        }
        return
    }
}

