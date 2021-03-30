//
//  ListViewController.swift
//  GroceryGuru
//
//  Created by Mobile App on 3/26/21.
//

import UIKit

class ListViewController: UIViewController {
    
    private let listId: String
    
    init(listId: String) {
        self.listId = listId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This tableView must be created here, rather than in the story board to prevent weird errors
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ListViewCell.nib(), forCellReuseIdentifier:ListViewCell.identifier)
        tableView.register(ListHeaderView.nib(), forHeaderFooterViewReuseIdentifier:ListHeaderView.identifier)
        return tableView
    }()
    
    var listData = ListResponse() {
        didSet {
            DispatchQueue.main.async {
                print("Table reload with new data")
                print(String(self.listData.count) + " sections")
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.getData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func getData() {
        let listRequest = ListRequest(list_id: listId)
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return listData.count // The number of sections is the number of entries in the listData array
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50 // This is because the view is height 50 in the ListViewCell.xib
    }
    
    // Use custom header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ListHeaderView.identifier) as! ListHeaderView
        view.configure(title: listData[section].name) // TODO - add buttons here that do things
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData[section].items.count // Set the number of sections to the number of items in that section
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let text = listData[indexPath.section].items[indexPath.row].itemDescription
        let qty = listData[indexPath.section].items[indexPath.row].qty
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ListViewCell.identifier, for: indexPath) as! ListViewCell
        
        cell.configure(title: text, qty: qty)
        
        return cell
    }
}
