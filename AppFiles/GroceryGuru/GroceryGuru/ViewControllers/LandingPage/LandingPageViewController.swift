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

public var deleted = true

class LandingPageViewController: UIViewController {
    
    @IBOutlet weak var createListButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    var loginDetails = LoginResponse()
    
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
        let allListRequest = AllListRequest()
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
                        deleted = false
                    }
                    print(error)
                case .success(let response):
                    print("List has been deleted \(response)")
                    deleted = response.result
                }
            }
            
            if(deleted){
                allListData.remove(at: indexPath.item)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            return
        }
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem){
        self.tableView.isEditing = !self.tableView.isEditing
        sender.title = (self.tableView.isEditing) ? "Done" : "Edit"
    }

}

extension LandingPageViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This list was tapped: " + String(allListData[indexPath.row].listID))
        print("Its name is: " + allListData[indexPath.row].listName)
        
        tableView.deselectRow(at: indexPath, animated: true) // Unselect the previous list
        
        print("Now performing segue to individual list view!")
        
        let vc = ListViewController(listId: String(allListData[indexPath.row].listID))
        vc.title = allListData[indexPath.row].listName
        navigationController?.pushViewController(vc, animated:true)
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
        
        return cell
    }
    
}
