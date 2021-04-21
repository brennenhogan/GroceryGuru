//
//  OldListsController.swift
//  GroceryGuru
//
//  Created by Mobile App on 4/21/21.
//

import UIKit

class OldListsController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var allListData = AllListResponse() {
        didSet {
            DispatchQueue.main.async {
                print("Table reload with new data")
                self.tableView.reloadData()
            }
        }
    }
    
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
    /*
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if (editingStyle == .delete){
            let recipe_id = String(allRecipieData[indexPath.row].recipeID)
            
            let deleteRequest = DeleteRecipeRequest(recipe_id: recipe_id)
            deleteRequest.deleteRecipe { [weak self] result in
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
                allRecipieData.remove(at: indexPath.item)
                tableView.deleteRows(at: [indexPath], with: .automatic)
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
    } */
}

extension OldListsController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Unselect
        let listId = String(allListData[indexPath.row].listID)
        
        print("This list was tapped: " + listId)
        print("Its name is: " + allListData[indexPath.row].listName)
        /*
        tableView.deselectRow(at: indexPath, animated: true) // Unselect the previous list
        
        print("Now performing segue to individual recipe view!")
        
        selected_recipe_id = String(allRecipieData[indexPath.row].recipeID)
        selected_recipe_name = allRecipieData[indexPath.row].recipeName
        print(selected_recipe_id)
        print(selected_recipe_name)
        DispatchQueue.main.async{
            self.performSegue(withIdentifier: "LandingToDetailedRecipe", sender: self)
        } */
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
        //cell.recipeTitle.tag = item.recipeID
        //cell.recipeTitle.isEnabled = self.tableView.isEditing
        //cell.recipeTitleDelegate = self

        return cell
    }
    
}
/*
extension RecipePageViewController: RecipeTitleDelegate {
    func editTitle(recipe_id: Int, recipe_title: String) {
        let updateRecipeTitleRequest = UpdateRecipeTitleRequest(recipe_title: recipe_title, recipe_id: recipe_id)
        updateRecipeTitleRequest.updateRecipeTitle { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error editing recipe")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(_):
                print("Recipe edited")
                self?.getData()
            }
        }
    }
}
*/
