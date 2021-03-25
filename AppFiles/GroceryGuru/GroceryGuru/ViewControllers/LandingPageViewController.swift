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

class LandingPageViewController: UIViewController {
    
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var loginDetails = LoginResponse()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
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
        
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        guard let userText = userText.text else {return}
        guard let passwordText = passwordText.text else {return}
        let loginRequest = LoginRequest(username: userText, password: passwordText)
        loginRequest.postLogin { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let login):
                print(login.uuid)
                //
                self?.loginDetails = login
            }
        }
        
    }

}

