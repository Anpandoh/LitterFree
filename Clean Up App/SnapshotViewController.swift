//
//  SnapshotViewController.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 8/2/21.
//

import UIKit
import MapKit
import FirebaseStorage


class SnapshotViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    private let storage = Storage.storage().reference()
    var image = UIImage()
    let locationManager = CLLocationManager()
    //let imgpreviewvc = ViewController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds//can change
        self.imageView.image = image
        view.addSubview(sendButton)
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        view.addSubview(dismissButton)
        dismissButton.addTarget(self, action: #selector(didTapDismissButton), for: .touchUpInside)
        //imgpreviewvc.session?.stopRunning()//makes sure video feed isnt playing while viewing photo

    }
    

    private let dismissButton: UIButton = {
        let button = UIButton(frame: CGRect(x: -10, y: 25, width: 100, height: 100))
        button.setImage(UIImage(named: "Exit_Icon"), for: .normal)
        return button
    }()
    
    @IBAction func didTapDismissButton() {
        self.dismiss(animated: true)
    }
    
    
    
    
    //figure out how to dismiss viewcontroller - make sure the viewcontroller.session starts running again (stop it on the viewcontroller)
    
    
    
    
    private let sendButton: UIButton = { //button to send picture in
        let button = UIButton(frame: CGRect(x: 210, y: 60, width: 150, height: 30))
        button.setTitle("Submit Image", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 0.25 * button.bounds.size.height
        button.clipsToBounds = true
        return button
    }()
    
    @IBAction func didTapSendButton() {
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        let map = MapViewController()
        let latitude = String(map.manager.location?.coordinate.latitude ?? 0.0) //gets User's latitude from mapview class with LocationManager
        let longitude = String(map.manager.location?.coordinate.longitude ?? 0.0)//gets User's longitude from mapview class with LocationManager
        
        let imguploadtime = formatter.string(from: now)
        let metadataDict = [
            "Latitude":latitude,
            "Longitude":longitude,
            "Date":imguploadtime
        ]
        
        
        
        let Metadata = StorageMetadata()
        //Metadata.contentType = "images/png" FIREBASE IS BROKEN AND WILL ONLY ALLOW CUSTOM METADATA IF CONTENTTYPE AND OTHERS REMAIN UNSPECIFIED
        Metadata.customMetadata = metadataDict;
        
        //SampleUserName
        let username = ("Anpandoh")
        let imageData = image.pngData()!
        
        //uploadimagedata
        let ref = storage.child("images/" + imguploadtime + " " + username)
        ref.putData(imageData, metadata: Metadata, completion: { _, error in
            guard error == nil else {
                print("Failed to Upload")
                return
            }
            self.storage.child("images/" + imguploadtime + " " + username).downloadURL(completion: {url, error in //gets download URL
                guard let url = url, error == nil else {return}
                let urlString = url.absoluteString
                print("Image URL:" + urlString)
            })
        })
        //imgpreviewvc.session?.startRunning()
        self.dismiss(animated: true)
    }
    
    
    
    
    
    
}

