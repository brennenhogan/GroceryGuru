//
//  LaunchAnimationViewController.swift
//  GroceryGuru
//
//  Created by Brennen Hogan on 4/23/21.
//

import UIKit

class LaunchAnimationViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 67, y: 293, width: 256, height: 256))
        imageView.layer.cornerRadius = 10
        imageView.image = UIImage(named:"GG_Logo_Clear_256")
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.25, execute: {
            self.animate()
        })
    }
    
    private func animate(){
        UIView.animate(withDuration: 0.8, animations: {
            self.imageView.frame = CGRect(
                x: 131,
                y: 101,
                width: 128,
                height: 128
            )
            self.imageView.backgroundColor = UIColor(hex: 0x617757)
            self.view.backgroundColor = UIColor.white
        }){ (done) in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.55, execute: {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let vc = sb.instantiateInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = vc
            })
        }
    }
}
