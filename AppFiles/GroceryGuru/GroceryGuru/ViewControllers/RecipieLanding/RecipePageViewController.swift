//
//  RecipePageViewController.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/12/21.
//

import UIKit

class RecipePageViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var allRecipieData = AllRecipeResponse() {
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
        
        tableView.register(RecipeTableCell.nib(), forCellReuseIdentifier:RecipeTableCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
                
        self.getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getData()
        active_page = "O"
    }
    
    func getData() {
        let allRecipeRequest = AllRecipeRequest()
        allRecipeRequest.getRecipe { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error getting data")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(let allRecipes):
                self?.allRecipieData = allRecipes
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
    
    @IBAction func addRecipe(_ sender: UIButton){
        let alert = UIAlertController(title: "Enter a Recipe Name", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.view.tintColor = UIColor(hex: 0x7A916E)
        self.present(alert, animated: true, completion: nil)
        
        // Grab the value from the text field when the user clicks Create
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            //Create List Action
            let addRecipeRequest = AddRecipeRequest(name: (textField?.text)!)
            addRecipeRequest.addRecipe { [weak self] result in
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
    
    
}

extension RecipePageViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This recipe was tapped: " + String(allRecipieData[indexPath.row].recipeQty))
        print("Its name is: " + allRecipieData[indexPath.row].recipeName)
        
        tableView.deselectRow(at: indexPath, animated: true) // Unselect the previous list
        
        print("Now performing segue to individual recipe view!")
        
        selected_recipe_id = String(allRecipieData[indexPath.row].recipeID)
        selected_recipe_name = allRecipieData[indexPath.row].recipeName
        print(selected_recipe_id)
        print(selected_recipe_name)
        DispatchQueue.main.async{
            self.performSegue(withIdentifier: "LandingToDetailedRecipe", sender: self)
        }
    }
    
}

extension RecipePageViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRecipieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = allRecipieData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeTableCell.identifier, for: indexPath) as! RecipeTableCell
        
        cell.configure(title: item.recipeName, qty: item.recipeQty)
        cell.recipeTitle.tag = item.recipeID
        cell.recipeTitle.isEnabled = self.tableView.isEditing
        cell.recipeTitleDelegate = self

        return cell
    }
    
}

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
