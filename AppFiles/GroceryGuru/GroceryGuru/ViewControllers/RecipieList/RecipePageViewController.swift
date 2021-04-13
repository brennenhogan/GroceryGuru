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
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(RecipeTableCell.nib(), forCellReuseIdentifier:RecipeTableCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
                
        self.getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getData()
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
}

extension RecipePageViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This recipe was tapped: " + String(allRecipieData[indexPath.row].recipeQty))
        print("Its name is: " + allRecipieData[indexPath.row].recipeName)
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
        
        return cell
    }
    
}
