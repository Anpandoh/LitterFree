//
//  LoginOptionsViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/17/21.
//

import UIKit


class LoginOptionsViewController: UIViewController {
    
    
    @IBOutlet weak var portlandImage: UIImageView!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    private func setUpElements() {
        
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
        self.portlandImage.image = (UIImage(named: "Portland_Logo"))
        portlandImage.contentMode = .scaleAspectFill
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
