//
//  userPoints.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 10/8/22.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class userPoints {
    
    
    
    
    
    var userInfo  = Database.database().reference().child("Users")
    
    
    public func addPoints(NumberOfPoints pts: Int) throws {
        print("hiodawda")
        if Auth.auth().currentUser != nil {
            guard let userID = Auth.auth().currentUser?.uid else {
                print("No User ID Found");
                throw Constants.SignInError.noUserFound
            }
            userInfo.child(userID).child("points").getData(completion:  { error, snapshot in
                guard error == nil else {
                    self.userInfo.child(userID).child("points").setValue(pts)
                    print("First user upload")
                    return;
                }
                let currPoints = snapshot.value as? Int ?? 0
                self.userInfo.child(userID).child("points").setValue(currPoints + pts)
                
            });

            
        }
    }
    
    public func getPoints(completion: @escaping (_ points: Int) -> Void ) {
        var currPoints = 0;
        if Auth.auth().currentUser != nil {
//            DispatchQueue.main.async{
                let userID = Auth.auth().currentUser!.uid
                self.userInfo.child(userID).child("points").getData(completion:  { error, snapshot in
                    guard error == nil else {
                        //userInfo.child(userID).child("points").setValue(pts)
                        print(error!.localizedDescription)
                        print("heyyyyyy>")
                        currPoints = 0;
                        return;
                    }
                    currPoints = snapshot.value as? Int ?? 0
                    completion((Int)(currPoints))
                });
                
            }
            //print(currPoints)
            return 
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
