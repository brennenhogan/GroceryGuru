//
//  AddListViewController.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/15/21.
//

import UIKit
import CoreData

extension AddListViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView){
        if createButton.isHidden {
            textView.text.removeAll()
            
            createButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

class AddListViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    @IBOutlet weak var newListView: UIView!
    @IBOutlet weak var newListLabel: UILabel!
    @IBOutlet var oldListTableView: UITableView!
    @IBOutlet var recipeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(with:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        textView.becomeFirstResponder()
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        oldListTableView.register(OldListsCell.nib(), forCellReuseIdentifier:OldListsCell.identifier)
        oldListTableView.delegate = self
        oldListTableView.dataSource = self
        oldListTableView.isHidden = true
        
        recipeTableView.register(RecipeTableCell.nib(), forCellReuseIdentifier:RecipeTableCell.identifier)
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
        recipeTableView.isHidden = true
        
        self.getListData()
        self.getRecipeData()
    }
    
    //MARK: Actions
    
    @objc func keyboardWillShow(with notification: Notification){
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        bottomContraint.constant = keyboardHeight + 20
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func CreateAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
        alertController.view.tintColor = UIColor(hex: 0x7A916E)

        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func didChangeSegment(_ sender: UISegmentedControl) {
        let selection = sender.selectedSegmentIndex
        if (selection == 0) {
            print(selection)
            newListView.isHidden = false
            newListLabel.isHidden = false
            oldListTableView.isHidden = true
            recipeTableView.isHidden = true
        } else if (sender.selectedSegmentIndex == 1) {
            newListView.isHidden = true
            newListLabel.isHidden = true
            createButton.isHidden = true
            oldListTableView.isHidden = false
            recipeTableView.isHidden = true
            print(selection)
        } else if (sender.selectedSegmentIndex == 2) {
            newListView.isHidden = true
            newListLabel.isHidden = true
            createButton.isHidden = true
            oldListTableView.isHidden = true
            recipeTableView.isHidden = false
            print(selection)
        }
    }
    
    @IBAction func create(_ sender: UIButton) {
        //Prevents creation of list with blank title
        guard let listName = textView.text, !listName.isEmpty else {
            return
        }
        
        // Creates a new list
        // 0 for new list, 1 for previous list, 2 for recipes
        let segment = Int16(segmentedControl.selectedSegmentIndex)
        
        if( segment == 0 ){
            print("Create from scratch")
            
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
                    print("Now performing segue to detailed list page \(addListResponse.list_id)")
                    selected_list_id = String(addListResponse.list_id)
                    selected_list_name = listName
                    DispatchQueue.main.async{
                        self?.performSegue(withIdentifier: "unwindToLanding", sender: self)
                    }
                }
            }
            
        } else if( segment == 1 ){
            print("Create from old list")
        } else if ( segment == 2 ){
            print("Create from recipe")
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
            print("This list was tapped: " + String(allListData[indexPath.row].listID))
            print("Its name is: " + allListData[indexPath.row].listName)
            
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
                        
                        print("Now performing segue to landing page!")
                        DispatchQueue.main.async{
                            self?.performSegue(withIdentifier: "unwindToLanding", sender: self)
                        }
                    }
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) {(action: UIAlertAction!) -> Void in }
            
            alert.addAction(cancelAction)
            alert.addAction(createAction)
        } else if tableView == recipeTableView {
            print("This recipe was tapped: " + String(allRecipieData[indexPath.row].recipeID))
            print("Its name is: " + allRecipieData[indexPath.row].recipeName)
            
            selected_recipe_id = String(allRecipieData[indexPath.row].recipeID)
            selected_recipe_name = allRecipieData[indexPath.row].recipeName
            
            print("Now performing segue to recipe checking page!")
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: RecipeTableCell.identifier, for: indexPath) as! RecipeTableCell
            
            cell.configure(title: item.recipeName, qty: item.recipeQty)
            cell.recipeTitle.tag = item.recipeID
            cell.recipeTitle.isEnabled = false
            
            return cell
        } else {
            return UITableViewCell() // Required
        }
    }
    
}
