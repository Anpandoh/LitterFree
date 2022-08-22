//
//  UploadViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/30/21.
//

import UIKit
import Photos
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseDatabase




//var ref: DatabaseReference!


class UploadViewController: UIViewController {
    
    var db: DatabaseReference!
    //let geoCoder = CLGeocoder()


    var asset = PHAsset()
    private let storage = Storage.storage().reference()
    
    
    @IBOutlet var uploadImageView:UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //uploadImageView.contentMode = .scaleAspectFill
        self.view.backgroundColor = UIColor.black
        //uploadImageView.frame = view.bounds
        
        setUpElements()
        
        
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: CGSize(width: 414, height: 896), contentMode: .aspectFit, options: nil) { image, _ in
            self.uploadImageView.image = image
        }
        
    }
    
    
    
    func removeSubmitButton() {
        submitButton.alpha = 0;
    }
    
    
    
    
    
    @IBAction func didTapSendButton() {
        var latitude = ""
        var longitude = ""
        var photodate = ""
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        
        
        
        let defaultdate = Date(timeIntervalSince1970: 0.0)
        photodate = formatter.string(from: asset.creationDate ?? defaultdate)//if date cannot be found as for date
        latitude = String((asset.location?.coordinate.latitude) ?? 0.0)//create a function that if longitude and latitude = 0.0 ask for real location
        longitude = String((asset.location?.coordinate.longitude) ?? 0.0)
        print(photodate)
        print(latitude)
        print(longitude)

        
        
        
        
        if Double(latitude) == 0.0 && Double(longitude) == 0.0 {
            guard let selectLocation = self.storyboard?.instantiateViewController(identifier: "mapView") as? UINavigationController else {return}
            //collectionvc.modalPresentationStyle =  .fullScreen
            self.present(selectLocation, animated: true)
        }
        
        
        // group.enter()
        
        else {
        // group.notify(queue: .main) {
        let manager = PHImageManager.default()
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 128, height: 128), contentMode: .aspectFit, options: nil) { image, _ in
            let imageData = image?.jpegData(compressionQuality: 1.0)
            //date & time of imageupload
            let imguploadtime = formatter.string(from: now)
            
            //metadata uploading
            var metadataDict = [
                "Latitude": latitude,
                "Longitude":longitude,
                "Date":photodate
            ]
            
            
            
            let Metadata = StorageMetadata()
            //Metadata.contentType = "images/png" FIREBASE IS BROKEN AND WILL ONLY ALLOW CUSTOM METADATA IF CONTENTTYPE AND OTHERS REMAIN UNSPECIFIED
            Metadata.customMetadata = metadataDict;
            
            //SampleUserName
            let userID = Auth.auth().currentUser?.uid
            self.db = Database.database().reference()

            
            //uploadimagedata
            let ref = self.storage.child("images/" + imguploadtime + " " + userID!)
            ref.putData(imageData!, metadata: Metadata, completion: { _, error in
                guard error == nil else {
                    print("Failed to Upload")
                    return
                }
                self.storage.child("images/" + imguploadtime + " " + userID!).downloadURL(completion: {url, error in //gets download URL
                    guard let url = url, error == nil else {return}
                    let urlString = url.absoluteString
                    metadataDict["url"] = urlString
                    self.db.child("TrashInfo").child(userID!).child(imguploadtime).setValue(metadataDict)
                    print("Image URL:" + urlString)
                    self.presentingViewController!.dismiss(animated: true)
                })
            })
        }
    }
    }
    
    func setUpElements() {
        Utilities.styleSubmitButton(submitButton)
    }
    
    
    
}

