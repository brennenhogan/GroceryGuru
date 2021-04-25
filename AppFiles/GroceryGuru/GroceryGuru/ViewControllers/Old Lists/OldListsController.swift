//
//  OldListsController.swift
//  GroceryGuru
//
//  Created by Mobile App on 4/21/21.
//

import UIKit

class OldListsController: UIViewController, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!

    var allListData = AllListResponse() {
        didSet {
            DispatchQueue.main.async {
                print("Table reload with new data")
                if(!self.local){
                    self.tableView.reloadData()
                } else{
                    self.local = false
                }
            }
        }
    }
    var deleted = true
    var local = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(OldListsBiggerCell.nib(), forCellReuseIdentifier:OldListsBiggerCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
                
        self.getData()
    }
    
    func getData() {
        let allListRequest = AllListRequest(status: 1)
        allListRequest.getList { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error getting data")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(let allLists):
                self?.allListData = allLists
                print("Data received properly")
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
            let list_id = allListData[indexPath.row].listID
            
            let deleteRequest = DeleteListRequest(list_id: list_id)
            deleteRequest.deleteList { [weak self] result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.CreateAlert(title: "Error", message: "\(error)")
                        self?.deleted = false
                    }
                    print(error)
                case .success(let response):
                    print("List has been deleted \(response)")
                    self?.deleted = response.result
                }
            }
            
            if(self.deleted){
                allListData.remove(at: indexPath.item)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.local = true
            }
            
            return
        }
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem){
        self.tableView.isEditing = !self.tableView.isEditing
        sender.title = (self.tableView.isEditing) ? "Done" : "Edit"
        tableView.visibleCells.forEach{ cell in
            guard let cell = cell as? RecipeTableCell else { return }
            print(self.tableView.isEditing)
            cell.recipeTitle.isEnabled = self.tableView.isEditing
        }
    }
}

extension OldListsController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = allListData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: OldListsBiggerCell.identifier, for: indexPath) as! OldListsBiggerCell
        
        cell.configure(title: item.listName, qty: item.listQty)

        return cell
    }
    
}
