//
//  SignUpViewController.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/15/21.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var termsSwitch: UISwitch!
    
    var newUserDetails = NewUserResponse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        loginButton.isHidden = true
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
    
    func CreateAlert(title: String, message: String) {

            let alertController = UIAlertController(title: title, message:
                                                        message, preferredStyle: UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
        alertController.view.tintColor = UIColor(hex: 0x7A916E)

            self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func newAccount(_ sender: UIButton) {
        
        guard let userText = userText.text else {return}
        guard let passwordText = passwordText.text else {return}
        let newUserRequest = NewUserRequest(username: userText, password: passwordText)
        newUserRequest.postNewUser { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(let newUser):
                userUuid = newUser.uuid!
                self?.newUserDetails = newUser
                print("Now performing segue to landing page")
                DispatchQueue.main.async{
                    self?.performSegue(withIdentifier: "SignUpToLanding", sender: self)
                }
            }
        }
        
    }
    
    @IBAction func toggleButton( sender: UISwitch) {
        if (termsSwitch.isOn == true){
            loginButton.isHidden = false
        }
        else {
            loginButton.isHidden = true
        }
    }

}
