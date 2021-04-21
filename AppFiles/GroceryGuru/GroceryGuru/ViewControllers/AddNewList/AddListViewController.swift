//
//  AddListViewController.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/15/21.
//

import UIKit

class AddListViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var textView: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var newListView: UIView!
    @IBOutlet weak var instructions: UILabel!
    @IBOutlet var oldListTableView: UITableView!
    @IBOutlet var recipeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        createButton.backgroundColor = createButton.backgroundColor?.withAlphaComponent(0.50)
        
        oldListTableView.register(OldListsCell.nib(), forCellReuseIdentifier:OldListsCell.identifier)
        oldListTableView.delegate = self
        oldListTableView.dataSource = self
        oldListTableView.isHidden = true
        
        recipeTableView.register(OldListsCell.nib(), forCellReuseIdentifier:OldListsCell.identifier)
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
        recipeTableView.isHidden = true
        
        self.getListData()
        self.getRecipeData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        active_page = "O"
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object:self.textView, queue: OperationQueue.main) { (notification) -> Void in
            let textFieldName = self.textView as UITextField
            self.createButton.isEnabled = !textFieldName.text!.isEmpty
            self.createButton.backgroundColor = self.createButton.backgroundColor?.withAlphaComponent(self.createButton.isEnabled ? 1.0 : 0.50)
        }
    }
    
    //MARK: Actions
    
    func CreateAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
        alertController.view.tintColor = UIColor(hex: 0x7A916E)

        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        let selection = sender.selectedSegmentIndex
        if (selection == 0) {
            newListView.isHidden = false
            instructions.text = "Enter a name for your list"
            createButton.isHidden = false
            oldListTableView.isHidden = true
            recipeTableView.isHidden = true
        } else if (sender.selectedSegmentIndex == 1) {
            newListView.isHidden = true
            instructions.text = "Pick an old list from below"
            createButton.isHidden = true
            oldListTableView.isHidden = false
            recipeTableView.isHidden = true
        } else if (sender.selectedSegmentIndex == 2) {
            newListView.isHidden = true
            instructions.text = "Pick a recipe from below"
            createButton.isHidden = true
            oldListTableView.isHidden = true
            recipeTableView.isHidden = false
        }
    }
    
    @IBAction func create(_ sender: UIButton) {
        //Prevents creation of list with blank title
        guard let listName = textView.text, !listName.isEmpty else {
            return
        }
        
        let addListRequest = AddListRequest(listname: listName)
        addListRequest.addList { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(let response):
                let addListResponse = response
                selected_list_id = String(addListResponse.list_id)
                selected_list_name = listName
                DispatchQueue.main.async{
                    self?.performSegue(withIdentifier: "unwindToLanding", sender: self)
                }
            }
        }
            
    }
    
    var allListData = AllListResponse() {
        didSet {
            DispatchQueue.main.async {
                print("Table reload with new data")
                self.oldListTableView.reloadData()
            }
        }
    }
    
    func getListData() {
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
    
    var allRecipieData = AllRecipeResponse() {
        didSet {
            DispatchQueue.main.async {
                print("Table reload with new data")
                self.recipeTableView.reloadData()
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
                print(error)
            case .success(let allRecipes):
                self?.allRecipieData = allRecipes
                print("Data received properly")
            }
        }
    }
}

extension AddListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == oldListTableView {
            tableView.deselectRow(at: indexPath, animated: true) // Unselect the previous list
            
            let listId = String(allListData[indexPath.row].listID)
            
            let alert = UIAlertController(title: "Enter a New List Name", message: "", preferredStyle: .alert)

            alert.addTextField { (textField) in
                textField.text = ""
            }

            alert.view.tintColor = UIColor(hex: 0x7A916E)
            self.present(alert, animated: true, completion: nil)
            
            // Grab the value from the text field when the user clicks Create
            let createAction = UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists
                let createListRequest = CreatFromOldListRequest(name: (textField?.text)!, list_id: listId)
                createListRequest.createList { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let response):
                        print("List has been created with id = \(response.list_id)")
                        
                        DispatchQueue.main.async{
                            self?.performSegue(withIdentifier: "unwindToLanding", sender: self)
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
        } else if tableView == recipeTableView {
            print("This recipe was tapped: " + String(allRecipieData[indexPath.row].recipeID))
            print("Its name is: " + allRecipieData[indexPath.row].recipeName)
            
            selected_recipe_id = String(allRecipieData[indexPath.row].recipeID)
            selected_recipe_name = allRecipieData[indexPath.row].recipeName
            
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "NewListToRecipeCheck", sender: self)
            }
        } else {
            print("Error: Table View tapped does not exist")
        }
    }
    
}

extension AddListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == oldListTableView {
            return allListData.count
        } else if tableView == recipeTableView {
            return allRecipieData.count
        } else {
            return 0 // Required
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == oldListTableView {
            let item = allListData[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: OldListsCell.identifier, for: indexPath) as! OldListsCell
            
            cell.configure(title: item.listName, qty: item.listQty)
            
            return cell
        } else if tableView == recipeTableView {
            let item = allRecipieData[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: OldListsCell.identifier, for: indexPath) as! OldListsCell
            
            cell.configure(title: item.recipeName, qty: item.recipeQty)
            cell.myText.tag = item.recipeID
            cell.myText.isEnabled = false
            
            return cell
        } else {
            return UITableViewCell() // Required
        }
    }
    
}
