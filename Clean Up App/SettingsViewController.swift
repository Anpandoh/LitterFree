//
//  SettingsViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/20/21.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

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
        self.present(loginoptionvc, animated: true)
        print("Logged Out")
    }
    
    private func setUpElements(){
        Utilities.styleCancelButton(logOut)
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
