//
//  SignInViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/17/21.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var forgotpasswordButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard email != nil else {
            errorLabel.text = ("Fill in Email TextField")
            errorLabel.alpha = 1
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email!) { error in
            
            if error != nil {
                // Couldn't sign in
                self.showError(error!.localizedDescription)
            }
            
        }
        self.showError("Password Reset Link sent")
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        
        let error = validateFields()
        
        if error != nil {
            
            // There's something wrong with the fields, show error message
            self.showError(error!)
        }
        else {
            
            // Create cleaned versions of the text field
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Signing in the user
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                
                if error != nil {
                    // Couldn't sign in
                    self.showError(error!.localizedDescription)
                }
                else {
                    print("Logged In")
                    self.presentingViewController!.dismiss(animated: true)
                }
            }
        }
    }
    private func validateFields() -> String? {
        
        // Check that all fields are filled in
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please input a email and password."
            
        }
        return nil
    }
    
    //sets up UI
    private func setUpElements(){
        errorLabel.alpha = 0
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        passwordTextField.isSecureTextEntry = true
    }
    
    private func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
}

