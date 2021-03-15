//
//  AddListViewController.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/15/21.
//

import UIKit
import CoreData

class AddListViewController: UIViewController {

    // MARK: Properties
    
    var context: NSManagedObjectContext!
    var list: List?
    
    // MARK: Outlets

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
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
        
        if let list = list {
            textView.text = list.title
            textView.text = list.title
            segmentedControl.selectedSegmentIndex = Int(list.items)
        }
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
    
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        textView.resignFirstResponder()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismissAndResign()
    }
    
    @IBAction func done(_ sender: UIButton) {
        guard let title = textView.text, !title.isEmpty else {
            //Could add alert here
            return
        }
        
        // Update if created otherwise create a new list
        if let list = self.list {
            list.title = title
            list.items = Int16(segmentedControl.selectedSegmentIndex)
        } else {
            let list = List(context: context)
            list.title = title
            list.items = Int16(segmentedControl.selectedSegmentIndex)
        }
        do {
            try context.save()
            dismissAndResign()
        } catch {
            print("Error saving list: \(error)")
        }
            }

}

extension AddListViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView){
        if doneButton.isHidden {
            textView.text.removeAll()
            //textView.textColor = .white
            
            doneButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

