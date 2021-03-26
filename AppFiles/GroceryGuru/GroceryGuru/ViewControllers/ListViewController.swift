//
//  ListViewController.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/26/21.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var listData = ListResponse() {
        didSet {
            DispatchQueue.main.async {
                print("Table reload with new data")
                self.tableView.reloadData()
                self.navigationItem.title = "\(self.listData.count) Items"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.getData()
    }
    
    func getData() {
        let listRequest = ListRequest()
        listRequest.getList { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error getting data")
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(let list):
                self?.listData = list
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
}

extension ListViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped cell!!")
    }
    
}

extension ListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        
        let item = listData[0].items[indexPath.row]
        
        cell.textLabel?.text = item.itemDescription
        cell.detailTextLabel?.text = String(item.qty)
        
        return cell
    }
}
