//
//  ResetPasswordViewController.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 3/24/21.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var oldPasswordText: UITextField!
    @IBOutlet weak var newPasswordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var userDetails = NewUserResponse()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
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
        
        // Sets the Back Button Sizing and Font
        let fontAttr = [
            NSAttributedString.Key.font: UIFont(name: "Roboto-Regular", size: 28)!
        ]
        
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = fontAttr
        
        let navbarAppearance = UINavigationBarAppearance()
        navbarAppearance.buttonAppearance = buttonAppearance
        UINavigationBar.appearance().standardAppearance = navbarAppearance
        
    }
    
    func CreateAlert(title: String, message: String) {

            let alertController = UIAlertController(title: title, message:
                                                        message, preferredStyle: UIAlertController.Style.alert)

        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
        alertController.view.tintColor = UIColor(hex: 0x7A916E)

            self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        
        guard let userText = userText.text else {return}
        guard let oldPasswordText = oldPasswordText.text else {return}
        guard let newPasswordText = newPasswordText.text else {return}
        let resetPasswordRequest = ResetPasswordRequest(username: userText, old_password: oldPasswordText, new_password: newPasswordText)
        resetPasswordRequest.putPassword { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.CreateAlert(title: "Error", message: "\(error)")
                }
                print(error)
            case .success(let user):
                userUuid = user.uuid!
                self?.userDetails = user
                print("Now performing segue to landing page")
                DispatchQueue.main.async{
                    self?.performSegue(withIdentifier: "ResetToLanding", sender: self)
                }
            }
        }
        
    }

}

