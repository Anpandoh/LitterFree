//
//  LoginOptionsViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/17/21.
//

//import UIKit
import FirebaseAuthUI
import FirebaseEmailAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
import FirebasePhoneAuthUI

class loginManager {
    static func loginScreen(delegate:FUIAuthDelegate) -> UINavigationController {
        let authUI = FUIAuth.defaultAuthUI() // get the defaultAuthUI
        authUI!.delegate = delegate
        
        let providerApple = FUIOAuth.appleAuthProvider()
        let providerGoogle = FUIGoogleAuth(authUI: authUI!)

        
        
        let providers: [FUIAuthProvider] = [
            FUIEmailAuth(),
            providerGoogle,
            providerApple,
            //FUIFacebookAuth(),
            //FUITwitterAuth(),
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
        ]
        authUI!.providers = providers
        //set the class that implements the FUIAuthDelegate protocol for callback
        
        
        func application(_ app: UIApplication, open url: URL,
                         options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
            let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
            if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
                return true
            }
            // other URL handling goes here.
            return false
        }
        let authViewController = authUI!.authViewController()
        
        authViewController.modalPresentationStyle = .fullScreen
        
        return authViewController
        
    }
}
