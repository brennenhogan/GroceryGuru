//
//  LandingPageViewController.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/24/21.
//

import UIKit

extension UIColor {

    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }

}

/* GLOBAL VARIABLES */
public var userUuid = ""
public var selected_list_id = ""
public var selected_list_name = ""
public var selected_recipe_id = ""
public var selected_recipe_name = ""
public var active_page = "O" // L for landing, D for detailed list, O for other
public var create_recipe_import = 0 // 0 for new list, 1 for import to existing

class LandingPageViewController: UIViewController, TableViewCellDelegate {

    @IBOutlet weak var createListButton: UIButton!
    @IBOutlet var tableView: UITableView!

    var deleted = true
    var loginDetails = LoginResponse()
    var timer = Timer()
    
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
        self.navigationItem.setHidesBackButton(true, animated: false)
        configureNavigationBar()
        configureCreateListButton()
        
        tableView.register(LandingListCell.nib(), forCellReuseIdentifier:LandingListCell.identifier)
        
        tableView.delegate = self
        tableView.dataSource = self
                
        self.getData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.getData()
        active_page = "L" // Sets the active page to be landing each time the page appears
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            // Invalidate the timer if we are no longer on the landing list page
            if(active_page != "L"){
                self.timer.invalidate()
            }

            // Makes a getData-like request, but with conditional updating
            let allListRequest = AllListRequest(status: 0)
            allListRequest.getList { [weak self] result in
                switch result {
                case .failure(let error):
                    print("Error getting data")
                    DispatchQueue.main.async {
                        self?.CreateAlert(title: "Error", message: "\(error)")
                    }
                    print(error)
                case .success(let allLists):
                    // Updates if a new list is shared with the user
                    if(self?.allListData.count != allLists.count){
                        self?.allListData = allLists
                    }
                }
            }
        }
        timer.tolerance = 0.2
        RunLoop.current.add(timer, forMode: .common)
    }
    
    private func configureCreateListButton() {
        let dark_sage = UIColor(hex: 0x7A916E)
        let origImage = UIImage(systemName: "pencil")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        createListButton.setImage(tintedImage, for: .normal)
        createListButton.tintColor = dark_sage

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
        
    }
    
    func getData() {
        let allListRequest = AllListRequest(status: 0)
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

            let alertController = UIAlertController(title: title, message:
                                                        message, preferredStyle: UIAlertController.Style.alert)

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
            }
            
            return
        }
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem){
        self.tableView.isEditing = !self.tableView.isEditing
        sender.title = (self.tableView.isEditing) ? "Done" : "Edit"
        tableView.visibleCells.forEach{ cell in
            guard let cell = cell as? LandingListCell else { return }
            cell.myText.isEnabled = tableView.isEditing
        }
    }
    
    func textFieldDidEndEditing(cell: LandingListCell, name: String) -> () {
        
        let path = tableView.indexPathForRow(at: cell.convert(cell.bounds.origin, to: tableView))
        let list_id = allListData[path?.row ?? 0].listID
        
        let updateRequest = UpdateListRequest(name: name, list_id: list_id)
        updateRequest.updateList { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let response):
                print("List has been updated \(response)")
                self?.getData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {}
}

extension LandingPageViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This list was tapped: " + String(allListData[indexPath.row].listID))
        print("Its name is: " + allListData[indexPath.row].listName)
        
        tableView.deselectRow(at: indexPath, animated: true) // Unselect the previous list
        
        print("Now performing segue to individual list view!")
        
        selected_list_id = String(allListData[indexPath.row].listID)
        selected_list_name = allListData[indexPath.row].listName
        print(selected_list_id)
        print(selected_list_name)
        DispatchQueue.main.async{
            self.performSegue(withIdentifier: "LandingToDetailed", sender: self)
        }
    }
    
}

extension LandingPageViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = allListData[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LandingListCell.identifier, for: indexPath) as! LandingListCell
        
        cell.configure(title: item.listName, qty: item.listQty)
        cell.shareBtn.tag = item.listID
        cell.myText.isEnabled = tableView.isEditing
        cell.delegate = self
        cell.shareListButtonDelegate = self
        
        return cell
    }
    
}


extension LandingPageViewController: ShareListButtonDelegate {
    
    
    func shareList(list_id: Int) {
        
        
        let alert = UIAlertController(title: "Enter a user to share with", message: "", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.text = ""
        }

        alert.view.tintColor = UIColor(hex: 0x7A916E)
        self.present(alert, animated: true, completion: nil)
        
        // Grab the value from the text field when the user clicks Create
        let createAction = UIAlertAction(title: "Share", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            //Share List Action
            let name = (textField?.text)!
            let shareListRequest = ShareListRequest(name: name, list_id: list_id)
            shareListRequest.shareList { [weak self] result in
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.CreateAlert(title: "Error", message: "\(error)")
                    }
                    print(error)
                case .success(let response):
                    DispatchQueue.main.async {
                        self?.CreateAlert(title: "Success", message: "List has been shared with \(name)")
                    }
                    print("Share permissions have been updated \(response)")
                    self?.getData()
                }
            }
            return
            
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
