//
//  SignInViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/17/21.
//

import UIKit
//import FirebaseAuth
import FirebaseAuthUI


class customizedAuthViewController : FUIAuthPickerViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let portlandImage = UIImageView(frame: UIScreen.main.bounds)
        portlandImage.image = (UIImage(named: "Portland_Logo"))
        portlandImage.contentMode = .scaleAspectFill
        let scrollView = view.subviews[0]
        let contentView = scrollView.subviews[0]
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        view.backgroundColor = .clear
        view.insertSubview(portlandImage, at: 0)
        //view.title = "Please Log In"
        
        
        
        
        //emailButton
        let firstButton = contentView.subviews[0].subviews[0]
        guard let emailButton = firstButton as? UIButton else {
            return
        }
        
        //remove cancel button
        self.navigationItem.leftBarButtonItem = nil
        
        
        
        
        
        //Change button styles
        Utilities.styleFilledButton(emailButton)
        for each in contentView.subviews[0].subviews {
            if let button = each as? UIButton {
                button.layer.cornerRadius = 0.25 * button.bounds.size.height
                ///do any other button customization here
            }
        }

        
    }

}

