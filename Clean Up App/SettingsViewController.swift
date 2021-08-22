//
//  SettingsViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/20/21.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var logOut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        guard let loginoptionvc = self.storyboard?.instantiateViewController(identifier: "loginNav") as? UINavigationController else {return}
        
        loginoptionvc.modalPresentationStyle = .fullScreen
        self.present(loginoptionvc, animated: true)
        print("Logged Out")
        hideUser()
    }
    
    private func setUpElements(){
        Utilities.styleCancelButton(logOut)
        Utilities.styleLabelSimple(userLabel)
        userLabel.alpha = 0
    }
    
    private func showUser(_ message:String) {
        userLabel.text = message
        userLabel.alpha = 1
    }
    
    private func hideUser() {
        userLabel.alpha = 0
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            showUser("Signed in as: " + (Auth.auth().currentUser?.email)!)
        }
    }
    

}
