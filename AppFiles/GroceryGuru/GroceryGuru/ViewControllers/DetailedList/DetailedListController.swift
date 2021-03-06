//
//  DetailedListController.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/26/21.
//

import UIKit

class DetailedListController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var listData = ListResponse() {
        didSet {
            if(self.local_version < self.server_version || self.initial){
                DispatchQueue.main.async {
                    print("Local \(self.local_version) Server \(self.server_version)")
                    print("Table reload with new data")
                    print(String(self.listData.stores.count) + " sections")
                    self.tableView.reloadData()
                    self.local_version = self.server_version
                    self.initial = false
                }
            }
        }
    }
    
    var hiddenSections = Set<Int>() // Hidden sections for collapsable
    var initial = true // Indicates that a list is loading for the first time
    var collapsing = false // Indicates that a section of the table view is collapsing
    var deleted = true
    var timer = Timer() // Timer for shared lists
    var server_version = -1 // Version of the list from the API
    var local_version = -1 // Version of the list locally on the device
    var filter_selection = 0
    var user_count = -1
    var newestIndexPath = IndexPath()
    var newestSection = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCount()
        self.getData()
        self.navigationItem.title = selected_list_name
        configureNavigationBar()
        
        tableView.register(ListViewCell.nib(), forCellReuseIdentifier:ListViewCell.identifier)
        tableView.register(ListHeaderView.nib(), forHeaderFooterViewReuseIdentifier:ListHeaderView.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 30
                
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)


    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getCount()
        self.getData()
        active_page = "D"
        
        print("Users with list access: \(self.user_count)")
        
        // Creates the timer for collaborative editing if multiple users have access to the list
        if(self.user_count > 1){
            self.createTimer()
        }

    }
    
    private func getSection(store_id: Int) -> Int {
        for (index, store) in listData.stores.enumerated(){
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
        backButton.action = #selector(barButtonAction)
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        
    }
    
    @objc func barButtonAction(){
        self.timer.invalidate()
    }
    
    func getData() {
        let listRequest = ListRequest(list_id: selected_list_id, filter: self.filter_selection)
        listRequest.getList { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error getting data")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(let list):
                self!.server_version = Int(list.version)!
                self?.listData = list
                print("Data received properly")
            }
        }
    }
    
    func getCount() {
        let ownerCountRequest = OwnerCountRequest(list_id: selected_list_id)
        ownerCountRequest.getCount() { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error getting data")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(let response):
                print("Data received properly")
                print(response)
                self!.user_count = response.count
            }
        }
    }
    
    func createTimer(){
        let interval = energy_saver ? 10.0 : 1.0
        
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            
            // Invalidate the timer if we are no longer on the detailed list page
            if(active_page != "D"){
                self.timer.invalidate()
            }

            print("Timer fired!")
            
            // Gets the current version of the list
            let listVersionRequest = ListVersionRequest(list_id: selected_list_id)
            listVersionRequest.getVersion { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let list):
                    self?.server_version = list.version
                }
            }
            
            print(self.server_version)
            print(self.local_version)
            
            // Check to see the server version is more up to date than the local
            if(self.server_version > self.local_version){
                print("Getting new data")
                self.getData()
            }

        }
        timer.tolerance = 0.2
        RunLoop.current.add(timer, forMode: .common)
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
                        self?.deleted = false
                    }
                    print(error)
                case .success(let response):
                    print("List has been deleted \(response)")
                    self?.local_version += 1
                    self?.deleted = response.result
                }
            }
            
            if(self.deleted){
                var items = listData.stores[indexPath.section].items
                items.remove(at: indexPath.row)
                listData.stores[indexPath.section].items = items
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            return
        }
    }
    
    @IBAction func recipeImport(_ sender: UIButton){
        self.timer.invalidate()
    }
    
    @IBAction func addStore(_ sender: UIButton){
        let current_section_count = self.listData.stores.count
        
        //Create List Action
        let addStoreRequest = AddStoreRequest(storename: "")
        addStoreRequest.addStore { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("Store has been created \(response.store_id)")
                self!.local_version += 1
                self?.newestSection = current_section_count
                
                let listElement = ListElement(items: [], store_id: response.store_id, name: "")
                self?.listData.stores.append(listElement)
                DispatchQueue.main.async {
                    self?.tableView.insertSections([current_section_count], with: .automatic)
                    let sectionIndexPath = IndexPath(row: NSNotFound, section: current_section_count)
                    self?.tableView.scrollToRow(at: sectionIndexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem){
        self.tableView.isEditing = !self.tableView.isEditing
        sender.title = (self.tableView.isEditing) ? "Done" : "Edit"
                
        tableView.visibleCells.forEach{ cell in
            guard let cell = cell as? ListViewCell else { return }
            cell.itemName.isEnabled = tableView.isEditing
            cell.itemQty.isEnabled = tableView.isEditing
            cell.checkBtn.isHidden = tableView.isEditing
            cell.itemName.borderStyle = (self.tableView.isEditing) ? .roundedRect : .none
            cell.itemQty.borderStyle = (self.tableView.isEditing) ? .roundedRect : .none
        }
        
        for i in 0...listData.stores.count {
            guard let header = tableView.headerView(forSection: i) as? ListHeaderView else { return }
            header.deleteButton.isHidden = !tableView.isEditing
            header.storeName.isEnabled = tableView.isEditing
            header.addButton.isHidden = tableView.isEditing
            header.storeName.borderStyle = (self.tableView.isEditing) ? .roundedRect : .none
        }
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        self.tableView.endEditing(true)
        self.filter_selection = sender.selectedSegmentIndex
        self.getData()
        self.initial = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension DetailedListController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Unselect the tapped item
    }
}

extension DetailedListController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listData.stores.count // The number of sections is the number of entries in the listData array
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35 // This is because the view is height 35 in the ListViewCell.xib
    }
    
    // Use custom header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ListHeaderView.identifier) as! ListHeaderView
        view.configure(title: listData.stores[section].name, storeID: listData.stores[section].store_id)

        
        view.storeName.isEnabled = tableView.isEditing
        view.addButton.isHidden = tableView.isEditing
        view.deleteButton.isHidden = !tableView.isEditing
        
        view.addItemDelegate = self
        view.deleteStoreDelegate = self
        view.editStoreDelegate = self
        view.expandSectionDelegate = self
        
        if(hiddenSections.contains(section)){
            view.expandButton.isSelected = true
        } else {
            view.expandButton.isSelected = false
        }
        
        if newestSection == section {
            newestSection = -1
            view.storeName.isEnabled = true
            view.storeName.resignFirstResponder()
            view.storeName.becomeFirstResponder()
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
        
        if indexPath.elementsEqual(self.newestIndexPath) {
            cell.itemName.isEnabled = true
            cell.itemName.resignFirstResponder()
            cell.itemName.becomeFirstResponder() // Keyboard pop up on new item's description
        }
                
        return cell
    }
}

extension DetailedListController: ItemQuantityDelegate {
    func editQty(cell: ListViewCell, item_id: Int, item_qty: Int) {
        let updateStoreNameRequest = UpdateItemQuantityRequest(item_id: item_id, item_qty: String(item_qty))
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
                self!.local_version += 1
                
                // Handles case where edit ends due to section collapse
                if(self!.collapsing){
                    self?.getData()
                    self!.collapsing = false
                } else {
                    DispatchQueue.main.async {
                        let indexPath = self!.tableView.indexPath(for: cell)!
                        self!.listData.stores[indexPath.section].items[indexPath.row].qty = item_qty
                    }
                }
            }
        }
    }
}

extension DetailedListController: ItemDescriptionDelegate {
    func editDescription(cell: ListViewCell, item_id: Int, item_description: String) {
        let updateItemDescriptionRequest = UpdateItemDescriptionRequest(item_id: item_id, item_description: item_description)
        updateItemDescriptionRequest.updateItemDescription { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("List has been updated \(response)")
                self!.local_version += 1
                
                // Handles case where edit ends due to section collapse
                if(self!.collapsing){
                    self?.getData()
                    self!.collapsing = false
                } else {
                    DispatchQueue.main.async {
                        let indexPath = self!.tableView.indexPath(for: cell)!
                        self!.listData.stores[indexPath.section].items[indexPath.row].itemDescription = item_description
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

extension DetailedListController: CheckButtonDelegate {
    func markItem(cell: ListViewCell, item_id: Int, check: Int) {
        let updatePurchasedRequest = UpdatePurchasedRequest(item_id: item_id, purchased: check)
        updatePurchasedRequest.updateItemPurchased { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("Item purchased has been updated \(response)")
                self!.local_version += 1
                DispatchQueue.main.async {
                    let indexPath = self!.tableView.indexPath(for: cell)!

                    if(self?.filter_selection == 0){
                        self!.listData.stores[indexPath.section].items[indexPath.row].purchased = check
                    } else if(self?.filter_selection == 1){
                        var items = self?.listData.stores[indexPath.section].items
                            items!.remove(at: indexPath.row)
                            self?.listData.stores[indexPath.section].items = items!
                            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
        return
    }
}

extension DetailedListController: AddItemDelegate {
    func addItem(storeID: Int) {
        let section = self.getSection(store_id: storeID)
        let current_row_count = self.listData.stores[section].items.count
        
        // Add Item Action
        let addItemRequest = AddItemRequest(description: "", list_id: selected_list_id, store_id: storeID, qty: "1") // Inserts an item with no description
        
        addItemRequest.addItem { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("Item has been created \(response)")
                self!.local_version += 1

                var items = self?.listData.stores[section].items
                let item = Item(itemDescription: "", itemID: response.item_id, listID: Int(selected_list_id)!, purchased: 0, qty: 1) // Local copy of the item
                items?.append(item)
                self?.listData.stores[section].items = items!
                let indexPath = IndexPath(row: (current_row_count), section: section)
                self?.newestIndexPath = indexPath

                DispatchQueue.main.async {
                    self?.tableView.insertRows(at: [indexPath], with: .automatic) // Insert new item
                    self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
}

extension DetailedListController: ExpandSectionDelegate {
    func expandSection(storeID: Int) {
        let section = self.getSection(store_id: storeID)
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
            self.collapsing = true // Indicates that a section has been collapsed
            self.tableView.endEditing(true)
            self.hiddenSections.insert(section)
            self.tableView.deleteRows(at: indexPathsForSection(),
                                      with: .fade)
        }
    }
}

extension DetailedListController: DeleteStoreDelegate {
    func deleteStore(storeID: Int) {
        let section = self.getSection(store_id: storeID)
        print("deleting store: \(storeID)")
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
                    let indexSet = IndexSet(arrayLiteral: section)
                    DispatchQueue.main.async {
                        self!.listData.stores.remove(at: section)
                        self!.tableView.deleteSections(indexSet, with: .automatic)
                    }
                    self!.local_version += 1
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
    func editStore(cell: ListHeaderView, storeID: Int, store_name: String) {
        let section = self.getSection(store_id: storeID)
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
                self!.local_version += 1
                self!.listData.stores[section].name = store_name
                DispatchQueue.main.async {
                    if(!self!.tableView.isEditing){ // If store is new, allow edit but set to false afterwards
                        cell.storeName.isEnabled = false
                    }
                }
            }
        }
    }
}
