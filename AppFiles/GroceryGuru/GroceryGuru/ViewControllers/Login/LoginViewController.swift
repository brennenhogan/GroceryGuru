//
//  LoginViewController.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/24/21.
//

import UIKit

class LoginViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var saveUsername: UISwitch!
    
    var loginDetails = LoginResponse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigationBar()
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        userText.delegate = self
        passwordText.delegate = self
        
        // Sets the default values to the user preferences
        userText.text = defaults.string(forKey: "Name") ?? ""
        saveUsername.isOn = defaults.bool(forKey: "SaveName")
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
        
    @IBAction func login(_ sender: UIButton) {
        
        guard let userText = userText.text else {return}
        guard let passwordText = passwordText.text else {return}
        let loginRequest = LoginRequest(username: userText, password: passwordText)
        loginRequest.postLogin { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(let login):
                userUuid = login.uuid!
                self?.loginDetails = login
                let saveUsername = self?.defaults.bool(forKey: "SaveName") ?? false
                print("Now performing segue to landing page")
                DispatchQueue.main.async{
                    if saveUsername { // Saves the username at login if the user toggled save
                        self?.defaults.set(userText, forKey: "Name")
                    }
                    self?.performSegue(withIdentifier: "LoginToLanding", sender: self)
                }
            }
        }
        
    }
    
    @IBAction func toggleSwitch( sender: UISwitch) {
        defaults.set(saveUsername.isOn, forKey: "SaveName")
        
        // Erases the saved username if the user toggles off
        if !saveUsername.isOn{
            defaults.set("", forKey: "Name")
        }
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userText{
            userText.resignFirstResponder() // dismiss keyboard
        } else if textField == passwordText {
            passwordText.resignFirstResponder()
        }
        return true
    }
}
