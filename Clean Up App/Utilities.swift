//
//  Utilities.swift
//  customauth
//
//
//  Created by Christopher Ching on 2019-05-09.
//  Modified and Added too by Aneesh Pandoh
//  Copyright © 2019 Christopher Ching. All rights reserved.
//

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 209/255, blue: 88/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        textfield.layer.masksToBounds = true
        
    }
    
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 0.25 * button.bounds.size.height
        button.tintColor = UIColor.white
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.init(red: 48/255, green: 209/255, blue: 88/255, alpha: 1).cgColor
        button.layer.cornerRadius = 0.25 * button.bounds.size.height
        //button.tintColor = UIColor.black
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func styleCancelButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 0.25 * button.bounds.size.height
        button.tintColor = UIColor.white
        //button.titleLabel?.font = UIFont(name:"Bodoni 72 Oldstyle Book", size: 20.0)
    }
    
    static func styleLabelSimple(_ label:UILabel) {
        
        // Filled rounded corner style
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.init(red: 48/255, green: 209/255, blue: 88/255, alpha: 1).cgColor
        label.layer.cornerRadius = 0.5 * label.bounds.size.height
        label.tintColor = UIColor.white
        //label.font = UIFont(name:"Bodoni 72 Oldstyle Book", size: 20.0)

    }
    
    static func stylePointsLabel(_ label:UILabel) {
        
        // Filled rounded corner style
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.init(red: 253/255, green: 218/255, blue: 13/255, alpha: 1).cgColor
        label.layer.cornerRadius = 0.25 * label.bounds.size.height
        label.tintColor = UIColor.white
        //label.font = UIFont(name:"Bodoni 72 Oldstyle Book", size: 20.0)

    }
    
    
    static func styleSubmitButton(_ button:UIButton) {
        button.setTitle("Submit Image", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 0.25 * button.bounds.size.height
        button.clipsToBounds = true
        button.tintColor = UIColor.white

    }
    
    static func styleImgButton(_ button:UIButton) {
        button.backgroundColor = .systemGreen
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        button.layer.cornerRadius = 0.25 * button.bounds.size.width
        button.clipsToBounds = true
        button.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
        button.tintColor = .white
    }
    
    static func styleFloatingButton(button:UIButton) {
//        button.frame(forAlignmentRect: CGRect(x: 0, y: 0, width: 60, height: 60))
        //button.layer.masksToBounds = true
        button.layer.cornerRadius = button.frame.width/2
        button.backgroundColor = .systemGreen
        
        let icon = UIImage(systemName: "cart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
        button.setImage(icon, for: .normal)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.4
        button.tintColor = .white
    }
    
    public static var defaultColor: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    /// Return the color for Dark Mode
                    return .white
                } else {
                    /// Return the color for Light Mode
                    return .black
                }
            }
        } else {
            /// Return a fallback color for iOS 12 and lower.
            return .systemGray
        }
    }()
    
}
