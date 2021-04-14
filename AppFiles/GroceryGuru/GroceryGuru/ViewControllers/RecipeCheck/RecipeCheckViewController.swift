//
//  RecipeCheckViewController.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/14/21.
//

import UIKit

class RecipeCheckViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(RecipeCheckCell.nib(), forCellReuseIdentifier:RecipeCheckCell.identifier)
        tableView.register(RecipeHeaderView.nib(), forHeaderFooterViewReuseIdentifier:RecipeHeaderView.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
                
        self.getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getData()
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
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Enter a New List Name", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.view.tintColor = UIColor(hex: 0x7A916E)
        self.present(alert, animated: true, completion: nil)
        
        // Grab the value from the text field when the user clicks Create
        let createAction = UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists
            let createListRequest = CreatFromOldListRequest(name: (textField?.text)!, list_id: selected_recipe_id)
            createListRequest.createList { [weak self] result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let response):
                    print("List has been created with id = \(response.list_id)")
                    
                    /*print("Now performing segue to landing page!")
                    DispatchQueue.main.async{
                        self?.performSegue(withIdentifier: "unwindToLanding", sender: self)
                    }*/
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {(action: UIAlertAction!) -> Void in }
        
        alert.addAction(cancelAction)
        alert.addAction(createAction)
    }
}

extension RecipeCheckViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped cell!!")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension RecipeCheckViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return recipeData.count // The number of sections is the number of entries in the recipeData array
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 // This is because the view is height 50 in the RecipeViewCell.xib
    }
    
    // Use custom header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: RecipeHeaderView.identifier) as! RecipeHeaderView
        view.configure(title: recipeData[section].name, storeID: String(recipeData[section].store_id))

        view.storeName.isEnabled = false
        view.addButton.isHidden = true
        view.deleteButton.isHidden = true
        view.expandButton.isHidden = true
        view.deleteButton.isHidden = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeData[section].items.count // Set the number of sections to the number of items in that section
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = recipeData[indexPath.section].items[indexPath.row].itemDescription
        let qty = recipeData[indexPath.section].items[indexPath.row].qty
        let item_id = recipeData[indexPath.section].items[indexPath.row].itemID
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCheckCell.identifier, for: indexPath) as! RecipeCheckCell
        
        cell.configure(title: text, qty: qty)
        
        cell.checkBtn.isHidden = false
        cell.checkBtn.isSelected = (1 != 0) // TODO - api work here
        cell.checkButtonDelegate = self
                
        return cell
    }
}

extension RecipeCheckViewController: CheckRecipeButtonDelegate {
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
