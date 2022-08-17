//
//  SnapshotViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/2/21.
//

import UIKit
import MapKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import FirebaseDatabase




var ref: DatabaseReference!


class SnapshotViewController: UIViewController {
    

    var db = Database.database().reference()
    
    @IBOutlet var imageView: UIImageView!
    private let storage = Storage.storage().reference()
    var image = UIImage()
    let locationManager = CLLocationManager()

    @IBOutlet weak var submitButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //imageView.contentMode = .scaleAspectFill
        self.view.backgroundColor = UIColor.black
        //imageView.frame = view.bounds//can change
        self.imageView.image = image
//        view.addSubview(sendButton)
//        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        view.addSubview(dismissButton)
        dismissButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
        //imgpreviewvc.session?.stopRunning()//makes sure video feed isnt playing while viewing photo
        setUpElements()
        
    }
    
    
    private let dismissButton: UIButton = {
        let button = UIButton(frame: CGRect(x: -10, y: 25, width: 100, height: 100))
        button.setImage(UIImage(named: "Exit_Icon"), for: .normal)
        return button
    }()
    
    @IBAction func didTapDismissButton() {
        self.dismiss(animated: false) {
        }
    }
    
    
    
        
    

    
    @IBAction func didTapSendButton() {
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        let map = MapViewController()
        let latitude = String(map.manager.location?.coordinate.latitude ?? 0.0) //gets User's latitude from mapview class with LocationManager
        let longitude = String(map.manager.location?.coordinate.longitude ?? 0.0)//gets User's longitude from mapview class with LocationManager
        
        let imguploadtime = formatter.string(from: now)
        var metadataDict = [
            "Latitude":latitude,
            "Longitude":longitude,
            "Date":imguploadtime
        ]
        
        
        
        let Metadata = StorageMetadata()
        //Metadata.contentType = "images/png" FIREBASE IS BROKEN AND WILL ONLY ALLOW CUSTOM METADATA IF CONTENTTYPE AND OTHERS REMAIN UNSPECIFIED
        Metadata.customMetadata = metadataDict;
        
        //SampleUserName
        let userID = Auth.auth().currentUser?.uid
        let imageData = image.jpegData(compressionQuality: 1.0)!
        
        //uploadimagedata
        let ref = storage.child("images/" + imguploadtime + " " + userID!)
        ref.putData(imageData, metadata: Metadata, completion: { _, error in
            guard error == nil else {
                print("Failed to Upload")
                return
            }
            self.storage.child("images/" + imguploadtime + " " + userID!).downloadURL(completion:{url, error in //gets download URL
                    guard let url = url, error == nil else {return}
                    let urlString = url.absoluteString
                    metadataDict["url"] = urlString
                    self.db.child("TrashInfo").child(userID!).setValue(metadataDict)

                //metadataDict.add
                    print("Image URL:" + urlString)
                })
        })
        //imgpreviewvc.session?.startRunning()
        self.dismiss(animated: false)
    }
    
    func setUpElements() {
        Utilities.styleSubmitButton(submitButton)
    }
    
    
    
    
    
    
}

