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

            let alertController = UIAlertController(title: title, message:
                                                        message, preferredStyle: UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
        alertController.view.tintColor = UIColor(hex: 0x7A916E)

            self.present(alertController, animated: true, completion: nil)
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
}
