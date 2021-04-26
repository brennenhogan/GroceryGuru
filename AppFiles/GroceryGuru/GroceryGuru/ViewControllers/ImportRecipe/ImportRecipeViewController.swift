//
//  ImportRecipeViewController.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/18/21.
//

import UIKit

class ImportRecipeViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        self.navigationItem.title = "Import Recipe"
        
        tableView.register(ImportRecipeCell.nib(), forCellReuseIdentifier:ImportRecipeCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
        self.getRecipeData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        active_page = "O"
    }
    
    //MARK: Actions
    
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
    
    
    func CreateAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
        alertController.view.tintColor = UIColor(hex: 0x7A916E)

        self.present(alertController, animated: true, completion: nil)
    }
    
    var allRecipieData = AllRecipeResponse() {
        didSet {
            DispatchQueue.main.async {
                print("Table reload with new data")
                self.tableView.reloadData()
            }
        }
    }
    
    func getRecipeData() {
        let allRecipeRequest = AllRecipeRequest()
        allRecipeRequest.getRecipe { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error getting data")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
            case .success(let allRecipes):
                self?.allRecipieData = allRecipes
                print("Data received properly")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ImportRecipeViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Unselect the tapped item
        selected_recipe_id = String(allRecipieData[indexPath.row].recipeID)
        selected_recipe_name = allRecipieData[indexPath.row].recipeName
        
        print("Now performing segue to recipe checking page!")
        DispatchQueue.main.async{
            create_recipe_import = 1
            self.performSegue(withIdentifier: "RecipeImportToRecipeCheck", sender: self)
        }
    }
}

extension ImportRecipeViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRecipieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = allRecipieData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImportRecipeCell.identifier, for: indexPath) as! ImportRecipeCell
        
        cell.configure(title: item.recipeName, qty: item.recipeQty)
        cell.recipeName.tag = item.recipeID
        cell.recipeName.isEnabled = false
        
        return cell
    }
}
