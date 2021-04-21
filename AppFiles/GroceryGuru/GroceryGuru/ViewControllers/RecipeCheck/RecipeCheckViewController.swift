//
//  RecipeCheckViewController.swift
//  GroceryGuru
//
//  Created by Brendan Sailer on 4/14/21.
//

import UIKit

class RecipeCheckViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var createBtn: UIButton!
    
    var recipeData = RecipeResponse() {
        didSet {
            DispatchQueue.main.async {
                print("Table reload with new data")
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
        if(create_recipe_import==0){
            self.navigationItem.title = "Create from Recipe"
            createBtn.setTitle("Create List", for: .normal)
        } else{
            self.navigationItem.title = "Import Recipe"
            createBtn.setTitle("Import Recipe", for: .normal)
        }
        
        tableView.register(RecipeCheckCell.nib(), forCellReuseIdentifier:RecipeCheckCell.identifier)
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
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
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
        if(create_recipe_import==0){
            let alert = UIAlertController(title: "Enter a New List Name", message: "", preferredStyle: .alert)

            alert.addTextField { (textField) in
                textField.text = ""
            }

            alert.view.tintColor = UIColor(hex: 0x7A916E)
            self.present(alert, animated: true, completion: nil)
            
            // Grab the value from the text field when the user clicks Create
            let createAction = UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists
                let createListRequest = CreateListFromRecipeRequest(name: (textField?.text)!, recipe_id: selected_recipe_id)
                createListRequest.createList { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let response):
                        selected_list_id = String(response.list_id)
                        selected_list_name = (textField?.text)!
                        
                        print("Now performing segue to landing page!")
                        DispatchQueue.main.async{
                            self?.performSegue(withIdentifier: "recipeCheckToLanding", sender: self)
                        }
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
        } else if(create_recipe_import==1){
            let alert = UIAlertController(title: "Confirm Recipe Import", message: "", preferredStyle: .alert)


            alert.view.tintColor = UIColor(hex: 0x7A916E)
            self.present(alert, animated: true, completion: nil)
            
            // Grab the value from the text field when the user clicks Create
            let createAction = UIAlertAction(title: "Import", style: .default, handler: { _ in
                let importRecipeRequest = ImportRecipeRequest(list_id: selected_list_id, recipe_id: selected_recipe_id)
                importRecipeRequest.importRecipe { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(_):
                        print("Now performing segue to landing page!")
                        DispatchQueue.main.async{
                            create_recipe_import = 0
                            self?.performSegue(withIdentifier: "unwindToDetail", sender: self)
                        }
                    }
                }
            })
                
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) {(action: UIAlertAction!) -> Void in }
            
            alert.addAction(cancelAction)
            alert.addAction(createAction)
        }
    }
}

extension RecipeCheckViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        let checked = recipeData[indexPath.section].items[indexPath.row].checked
        
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeCheckCell.identifier, for: indexPath) as! RecipeCheckCell
        
        cell.configure(title: text, qty: qty)
        
        cell.checkBtn.tag = recipeData[indexPath.section].items[indexPath.row].itemID
        cell.checkBtn.isHidden = false
        cell.checkBtn.isSelected = (1 == checked)
        cell.checkButtonDelegate = self
                
        return cell
    }
}

extension RecipeCheckViewController: CheckRecipeButtonDelegate {
    func markItem(item_id: Int, check: Int) {
        let updateCheckedRequest = UpdateCheckedRequest(item_id: item_id, checked: check)
        updateCheckedRequest.updateItemChecked { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("Item checked has been updated \(response)")
                self?.getData()
            }
        }
        return
    }
}
